"""Add editable, native PowerPoint build animations from a named-shape manifest.

The package authoring runtime has no documented animation API. This small
postprocessor writes PresentationML timing, preserving all artwork and text.
Primary references:
https://learn.microsoft.com/en-us/office/open-xml/presentation/working-with-animation
https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.presentation.sequencetimenode
https://learn.microsoft.com/en-us/dotnet/api/documentformat.openxml.presentation.setbehavior

Manifest example:
{"slides":[{"slide":1,"stages":[
  {"trigger":"auto","effects":[{"targets":["title"],"effect":"floatUp"}]},
  {"trigger":"click","effects":[{"targets":["card-a*"],"effect":"fade"}]}
]}]}

Use a stage for each explanation beat, not for every text fragment. Targets
support exact shape names or shell wildcards. A panel and its text should enter
in the same beat. Existing timing is replaced deliberately. Playback must be
checked in native PowerPoint: schema/relationship checks cannot prove motion.
"""

from __future__ import annotations

import argparse
import fnmatch
import json
import re
from pathlib import Path
from zipfile import ZipFile

from lxml import etree as ET

P = "http://schemas.openxmlformats.org/presentationml/2006/main"
A = "http://schemas.openxmlformats.org/drawingml/2006/main"
NS = {"p": P, "a": A}
FILTERS = {
    "fade": ("fade", "10", "0"),
    "floatUp": ("fade", "10", "0"),
    "floatRight": ("fade", "10", "0"),
    "floatLeft": ("fade", "10", "0"),
    "wipeRight": ("wipe(right)", "22", "2"),
    "wipeDown": ("wipe(down)", "22", "4"),
}


def add(parent, name, **attrs):
    return ET.SubElement(parent, f"{{{P}}}{name}", {k: str(v) for k, v in attrs.items()})


def integer(value, low, high, label):
    if isinstance(value, bool) or not isinstance(value, int) or not low <= value <= high:
        raise ValueError(f"{label} must be an integer from {low} to {high}")
    return value


def named_shapes(root):
    result = []
    for item in root.findall(".//p:cNvPr", NS):
        shape = item.getparent().getparent()
        if shape.tag == f"{{{P}}}pic" and not item.get("name", "").strip():
            item.set("name", "art-" + item.get("id"))
        result.append({"id": item.get("id"), "name": item.get("name", ""),
                       "text": shape.find("p:txBody", NS) is not None})
    return result


def add_timing(root, spec):
    shapes = named_shapes(root)
    by_id = {s["id"]: s for s in shapes}
    next_id = 0

    def ct(parent, **attrs):
        nonlocal next_id
        next_id += 1
        return add(parent, "cTn", id=next_id, **attrs)

    def conditions(parent, delay):
        return add(add(parent, "stCondLst"), "cond", delay=delay)

    def behavior(parent, spid, duration, **attrs):
        cb = add(parent, "cBhvr", **attrs)
        timing = ct(cb, dur=duration, fill="hold")
        add(add(cb, "tgtEl"), "spTgt", spid=spid)
        return cb, timing

    def position_animation(parent, spid, duration, axis, offset):
        anim = add(parent, "anim", calcmode="lin", valueType="num")
        cb, _ = behavior(anim, spid, duration, additive="base")
        add(add(cb, "attrNameLst"), "attrName").text = axis
        values = add(anim, "tavLst")
        for tm, value in [(0, f"#{axis}{offset:+.5f}"), (100000, f"#{axis}")]:
            add(add(add(values, "tav", tm=tm), "val"), "strVal", val=value)

    def effect(parent, spid, kind, duration, delay, node_type, group):
        filt, preset, subtype = FILTERS[kind]
        eff = ct(add(parent, "par"), presetID=preset, presetClass="entr",
                 presetSubtype=subtype, fill="hold", grpId=group,
                 nodeType=node_type, decel="65000")
        conditions(eff, delay)
        children = add(eff, "childTnLst")
        show = add(children, "set")
        cb, ctime = behavior(show, spid, 1)
        conditions(ctime, 0)
        add(add(cb, "attrNameLst"), "attrName").text = "style.visibility"
        add(add(show, "to"), "strVal", val="visible")
        fade = add(children, "animEffect", transition="in", filter=filt)
        behavior(fade, spid, duration)
        if kind == "floatUp":
            position_animation(children, spid, duration, "ppt_y", 0.024)
        elif kind == "floatRight":
            position_animation(children, spid, duration, "ppt_x", -0.018)
        elif kind == "floatLeft":
            position_animation(children, spid, duration, "ppt_x", 0.018)

    for old in root.findall("p:timing", NS):
        root.remove(old)
    timing = ET.Element(f"{{{P}}}timing")
    # Schema order: transition, timing, extLst.
    extension = root.find("p:extLst", NS)
    if extension is None:
        root.append(timing)
    else:
        root.insert(root.index(extension), timing)
    main = ct(add(add(timing, "tnLst"), "par"), dur="indefinite",
              restart="never", nodeType="tmRoot")
    seq = add(add(main, "childTnLst"), "seq", concurrent="1", nextAc="seek", prevAc="skipTimed")
    timeline = add(ct(seq, dur="indefinite", nodeType="mainSeq"), "childTnLst")
    seen, report, text_builds = set(), [], set()
    stages = spec.get("stages", [])
    if not stages:
        raise ValueError("Each animated slide requires at least one stage")
    for i, stage in enumerate(stages):
        trigger = stage.get("trigger", "click")
        if trigger not in {"auto", "click"}:
            raise ValueError(f"Unsupported trigger: {trigger}")
        block = ct(add(timeline, "par"), fill="hold")
        conditions(block, "indefinite" if trigger == "click" else 0)
        group = ct(add(add(block, "childTnLst"), "par"), fill="hold")
        conditions(group, stage.get("delayMs", 0))
        children = add(group, "childTnLst")
        stage_shapes = []
        for entry in stage.get("effects", []):
            kind = entry.get("effect", "fade")
            if kind not in FILTERS:
                raise ValueError(f"Unsupported effect {kind}")
            duration = integer(entry.get("durationMs", 450), 100, 3000, "durationMs")
            delay = integer(entry.get("delayMs", 0), 0, 4000, "delayMs")
            targets = entry.get("targets", [])
            if not targets:
                raise ValueError("Animation effect requires named targets")
            matches = []
            for target in targets:
                found = [s for s in shapes if fnmatch.fnmatchcase(s["name"], target)]
                if not found:
                    raise ValueError(f"No shape matches {target!r}")
                for shape in found:
                    if shape["id"] not in [m["id"] for m in matches]:
                        matches.append(shape)
            for j, shape in enumerate(matches):
                if shape["id"] in seen:
                    raise ValueError(f"Duplicate entrance for {shape['name']!r}")
                seen.add(shape["id"])
                first = not stage_shapes
                nt = "clickEffect" if first and trigger == "click" else "withEffect"
                effect(children, shape["id"], kind, duration, delay, nt, 0)
                stage_shapes.append(shape["name"])
                if shape["text"]:
                    text_builds.add(shape["id"])
        if not stage_shapes:
            raise ValueError("Empty animation stage")
        report.append({"stage": i + 1, "trigger": trigger, "targets": stage_shapes})
    for evt, name in [("onPrev", "prevCondLst"), ("onNext", "nextCondLst")]:
        condition = add(add(seq, name), "cond", evt=evt, delay=0)
        add(add(condition, "tgtEl"), "sldTgt")
    if text_builds:
        builds = add(timing, "bldLst")
        for spid in sorted(text_builds, key=int):
            add(builds, "bldP", spid=spid, grpId=0)
    # Validate the references and IDs we just emitted, independent of geometry.
    time_ids = [x.get("id") for x in timing.findall(".//p:cTn", NS)]
    assert len(time_ids) == len(set(time_ids))
    assert all(x.get("spid") in by_id for x in timing.findall(".//p:spTgt", NS))
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path)
    parser.add_argument("target", type=Path)
    parser.add_argument("manifest", type=Path, nargs="?",
                        help="Optional explicit manifest; otherwise use chrome-* and b1-* through b4-*")
    parser.add_argument("--require-all", action="store_true")
    parser.add_argument("--report", type=Path)
    args = parser.parse_args()
    if args.source.resolve() == args.target.resolve():
        raise ValueError("Source and target paths must differ")
    specs = ({int(s["slide"]): s for s in json.loads(args.manifest.read_text())["slides"]}
             if args.manifest else {})
    reports = []
    with ZipFile(args.source) as source, ZipFile(args.target, "w") as target:
        slide_numbers = {int(re.fullmatch(r"ppt/slides/slide(\d+)\.xml", n).group(1))
                         for n in source.namelist() if re.fullmatch(r"ppt/slides/slide\d+\.xml", n)}
        if not args.manifest:
            for number in sorted(slide_numbers):
                root = ET.fromstring(source.read(f"ppt/slides/slide{number}.xml"))
                names = [shape["name"] for shape in named_shapes(root)]
                present = lambda prefix: any(fnmatch.fnmatchcase(n, prefix) for n in names)
                intro = []
                if present("chrome-*"):
                    intro.append({"targets": ["chrome-*"], "effect": "fade", "durationMs": 320})
                if not present("b1-*"):
                    raise ValueError(f"Slide {number} needs at least one b1-* object")
                intro.append({"targets": ["b1-*"], "effect": "floatUp", "durationMs": 500,
                              "delayMs": 90})
                stages = [{"trigger": "auto", "effects": intro}]
                variants = ["floatLeft", "fade", "floatUp", "floatRight"]
                for block in range(2, 5):
                    if present(f"b{block}-*"):
                        stages.append({"trigger": "click", "effects": [{
                            "targets": [f"b{block}-*"],
                            "effect": variants[(number + block) % len(variants)],
                            "durationMs": 420 if block % 2 == 0 else 500}]})
                specs[number] = {"slide": number, "stages": stages}
        if not set(specs) <= slide_numbers:
            raise ValueError("Manifest references a missing slide")
        if args.require_all and set(specs) != slide_numbers:
            raise ValueError("Every slide must have an animation spec")
        for info in source.infolist():
            content = source.read(info.filename)
            match = re.fullmatch(r"ppt/slides/slide(\d+)\.xml", info.filename)
            if match and (number := int(match.group(1))) in specs:
                root = ET.fromstring(content)
                stages = add_timing(root, specs[number])
                content = ET.tostring(root, xml_declaration=True, encoding="UTF-8", standalone=True)
                reports.append({"slide": number, "stages": stages})
            target.writestr(info, content)
    report = {"animatedSlides": len(reports), "nativePlaybackVerified": False, "slides": reports}
    if args.report:
        args.report.write_text(json.dumps(report, ensure_ascii=False, indent=2))
    print(json.dumps({"animatedSlides": len(reports), "nativePlaybackVerified": False}))


if __name__ == "__main__":
    main()

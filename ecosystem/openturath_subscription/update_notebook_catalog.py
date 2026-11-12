"""Script to update openturath_ai/functions/src/notebook_catalog.ts
with the 24 new masters and 240 new clones from Google Pro account,
while preserving legacy IDs and entity metadata.
"""

import json
from collections import defaultdict

def main():
    existing = json.load(open("/tmp/existing_entities.json"))
    masters = json.load(open("ecosystem/openturath_subscription/pro_account_master_catalog.json"))
    clones = json.load(open("ecosystem/openturath_subscription/pro_account_clones_catalog.json"))

    clones_by_cat = defaultdict(list)
    for c in clones:
        clones_by_cat[c["category_key"]].append({
            "name": c["title"],
            "id": c["id"],
            "url": c["url"]
        })

    # Read the bottom part of existing notebook_catalog.ts (AGENT_TO_ENTITY and helper functions)
    with open("openturath_ai/functions/src/notebook_catalog.ts", "r") as f:
        existing_ts = f.read()

    agent_to_entity_pos = existing_ts.find("export const AGENT_TO_ENTITY")
    if agent_to_entity_pos == -1:
        raise ValueError("Could not find AGENT_TO_ENTITY in notebook_catalog.ts")

    bottom_part = existing_ts[agent_to_entity_pos:]

    lines = [
        "/// ================================================================",
        "/// NOTEBOOK CATALOG & LOAD BALANCER POOL — OPENTURATH AI",
        "/// Generated from OPENTURATH_NOTEBOOK_CATALOG.md",
        "/// 24 Entitas Khazanah Turath x 10 Kloning Merata (Total 240 Clones + 24 Masters)",
        "/// Akun Pro Baru: hus180402@gmail.com (macbookairm1ku@gmail.com)",
        "/// ================================================================",
        "",
        "export interface NotebookEntityInfo {",
        "  code: string;",
        "  name: string;",
        "  masterId: string;",
        "  masterUrl: string;",
        "  legacyIds?: string[];",
        "  clones: Array<{ name: string; id: string; url: string }>;",
        "}",
        "",
        "export const NOTEBOOK_ENTITIES: Record<string, NotebookEntityInfo> = {"
    ]

    for code, info in existing.items():
        name = info["name"]
        new_master_id = masters[code]["notebook_id"]
        new_master_url = f"https://notebooklm.google.com/notebook/{new_master_id}"

        # Combine old master and old legacyIds into legacyIds
        old_master = info.get("masterId")
        old_legacy = info.get("legacyIds") or []
        legacy_ids = []
        if old_master and old_master != new_master_id:
            legacy_ids.append(old_master)
        for lid in old_legacy:
            if lid not in legacy_ids and lid != new_master_id:
                legacy_ids.append(lid)

        # Sort clones by name
        cat_clones = sorted(clones_by_cat[code], key=lambda x: x["name"])

        lines.append(f'  "{code}": {{')
        lines.append(f'    code: "{code}",')
        lines.append(f'    name: "{name}",')
        lines.append(f'    masterId: "{new_master_id}",')
        lines.append(f'    masterUrl: "{new_master_url}",')
        if legacy_ids:
            leg_str = json.dumps(legacy_ids)
            lines.append(f'    legacyIds: {leg_str},')
        lines.append("    clones: [")
        for clone in cat_clones:
            lines.append(f'      {{ name: "{clone["name"]}", id: "{clone["id"]}", url: "{clone["url"]}" }},')
        lines.append("    ],")
        lines.append("  },")

    lines.append("};")
    lines.append("")
    lines.append(bottom_part)

    new_content = "\n".join(lines)
    with open("openturath_ai/functions/src/notebook_catalog.ts", "w") as f:
        f.write(new_content)

    print("Successfully updated openturath_ai/functions/src/notebook_catalog.ts")

if __name__ == "__main__":
    main()

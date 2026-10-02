// OCR helper (macOS Vision). Usage: ocr <image> [langs]
// Prints: x y w h (pixels, top-left origin) | confidence | text
import AppKit
import Foundation
import Vision

let args = CommandLine.arguments
guard args.count > 1, let img = NSImage(contentsOfFile: args[1]),
  let cg = img.cgImage(forProposedRect: nil, context: nil, hints: nil)
else { print("cannot open image"); exit(1) }
let W = Double(cg.width), H = Double(cg.height)
let req = VNRecognizeTextRequest()
req.recognitionLevel = .accurate
req.usesLanguageCorrection = false
req.recognitionLanguages = args.count > 2 ? args[2].split(separator: ",").map(String.init) : ["id-ID", "en-US"]
try VNImageRequestHandler(cgImage: cg, options: [:]).perform([req])
for o in req.results ?? [] {
  guard let c = o.topCandidates(1).first else { continue }
  let b = o.boundingBox
  print(String(format: "%5.0f %5.0f %4.0f %3.0f | %.2f | %@", b.minX * W, (1 - b.maxY) * H, b.width * W, b.height * H, c.confidence, c.string))
}

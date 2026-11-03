#!/usr/bin/env python3
"""Generate a lab record PDF from a JSON spec, matching the course record format:
Times New Roman, 12pt body / 14pt headings, 1.5 line spacing (code block single-spaced).

Usage: python3 gen_record.py <spec.json> <output.pdf>
"""
import html
import json
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Any

CSS = """
@page { size: A4; margin: 20mm 16mm; }
* { box-sizing: border-box; }
body { font-family: 'Times New Roman', Times, serif; font-size: 12pt; line-height: 1.5; color: #000; }
.topbar { display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #000; padding-bottom: 6px; margin-bottom: 10px; }
.topbar .course { font-weight: bold; font-size: 14pt; }
.topbar .reg { font-weight: bold; font-size: 12pt; }
table.meta { width: 100%; border-collapse: collapse; margin-bottom: 14px; }
table.meta td { border: 1px solid #000; padding: 6px 8px; vertical-align: top; }
table.meta td.label { font-weight: bold; width: 32%; }
table.meta td.exno { font-weight: bold; width: 32%; }
table.meta td.title { font-weight: bold; text-align: center; }
h2.section { font-size: 14pt; font-weight: bold; margin: 16px 0 4px 0; }
p.body-text { margin: 4px 0 10px 0; text-align: justify; }
.codefile { font-weight: bold; font-size: 12pt; margin: 10px 0 2px 0; }
pre.code { font-family: 'Courier New', monospace; font-size: 10pt; line-height: 1; background: #fff; border: 1px solid #ccc; padding: 8px; white-space: pre-wrap; word-wrap: break-word; margin: 0 0 8px 0; }
.shot-block { margin: 8px 0 16px 0; page-break-inside: avoid; }
.shot-caption { font-style: italic; font-size: 11pt; margin-top: 4px; }
img.shot { max-width: 60%; display: block; margin: 6px auto; border: 1px solid #999; }
"""


def esc(s: str) -> str:
    return html.escape(s, quote=False)


def build_html(spec: dict[str, Any]) -> str:
    lab = spec
    code_blocks = []
    for f in lab.get("code_files", []):
        path = Path(f["path"])
        content = path.read_text(encoding="utf-8")
        code_blocks.append(
            f'<div class="codefile">{esc(f.get("label", path.name))}</div>'
            f'<pre class="code">{esc(content)}</pre>'
        )
    code_html = "\n".join(code_blocks)

    shot_blocks = []
    for shot in lab.get("screenshots", []):
        shot_path = Path(shot["path"]).resolve()
        caption = esc(shot.get("caption", ""))
        shot_blocks.append(
            f'<div class="shot-block"><img class="shot" src="file://{shot_path}">'
            f'<div class="shot-caption">{caption}</div></div>'
        )
    shots_html = "\n".join(shot_blocks) if shot_blocks else "<p class='body-text'><i>(see screenshots/ folder)</i></p>"

    description_html = "".join(
        f'<p class="body-text">{esc(p)}</p>' for p in lab["description"].split("\n\n")
    )
    aim_html = "".join(f'<p class="body-text">{esc(p)}</p>' for p in lab["aim"].split("\n\n"))
    result_html = "".join(f'<p class="body-text">{esc(p)}</p>' for p in lab["result"].split("\n\n"))

    return f"""<!DOCTYPE html>
<html><head><meta charset="utf-8"><style>{CSS}</style></head>
<body>
  <div class="topbar">
    <div class="course">{esc(lab['course'])}</div>
    <div class="reg">{esc(lab['regno'])}</div>
  </div>
  <table class="meta">
    <tr><td class="exno">Ex. No. {lab['ex_no']}</td><td class="title">{esc(lab['title'])}</td></tr>
    <tr><td class="label">Date of Exercise</td><td>{esc(lab.get('date', ''))}</td></tr>
    <tr><td class="label">Github Code Link (Keep as public)</td><td>{esc(lab.get('github_link', ''))}</td></tr>
    <tr><td class="label">Video Link (Google Drive Link)</td><td>{esc(lab.get('video_link', ''))}</td></tr>
  </table>

  <h2 class="section">Aim</h2>
  {aim_html}

  <h2 class="section">Description</h2>
  {description_html}

  <h2 class="section">Program</h2>
  {code_html}

  <h2 class="section">Output Screenshots</h2>
  {shots_html}

  <h2 class="section">Result</h2>
  {result_html}
</body></html>"""


def main() -> None:
    spec_path, out_path = sys.argv[1], sys.argv[2]
    spec = json.loads(Path(spec_path).read_text(encoding="utf-8"))
    doc_html = build_html(spec)

    with tempfile.NamedTemporaryFile("w", suffix=".html", delete=False) as f:
        f.write(doc_html)
        html_path = f.name

    out_path = str(Path(out_path).resolve())
    subprocess.run(
        [
            "google-chrome",
            "--headless=new",
            "--disable-gpu",
            "--no-sandbox",
            "--no-pdf-header-footer",
            f"--print-to-pdf={out_path}",
            f"file://{html_path}",
        ],
        check=True,
        capture_output=True,
    )
    print(f"Wrote {out_path}")


if __name__ == "__main__":
    main()

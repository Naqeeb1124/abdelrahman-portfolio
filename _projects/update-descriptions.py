import os
import re

projects_path = r"D:\downloads 2\abdelrahman-portfolio-starter\_projects"

for root, dirs, files in os.walk(projects_path):
    for file in files:
        if file.lower() == "index.md":
            file_path = os.path.join(root, file)
            with open(file_path, "r", encoding="utf-8") as f:
                lines = f.readlines()

            new_lines = []
            overview_lines = []
            in_overview = False

            for line in lines:
                stripped = line.strip()

                # Detect ## Overview line
                if stripped.lower().startswith("## overview"):
                    in_overview = True
                    continue

                # Detect next ## heading
                if in_overview and stripped.startswith("##"):
                    in_overview = False

                # Collect overview lines
                if in_overview:
                    overview_lines.append(stripped)
                    continue

                # Keep other lines
                new_lines.append(line)

            # Join overview lines for YAML front matter
            overview_text = " ".join(overview_lines).replace('"', '\\"')
            if not overview_text:
                overview_text = "Project description here"

            # Replace description in YAML front matter
            content = "".join(new_lines)
            content = re.sub(r'(description:\s*).*', f'description: "{overview_text}"', content, count=1)

            # Save file
            with open(file_path, "w", encoding="utf-8") as f:
                f.write(content)

print("Done updating descriptions!")

\
import re
import os
from datetime import datetime

def parse_markdown(md_content):
    sprints = []
    current_sprint = None
    current_microversion = None

    # Regex to identify Epic or Sprint headers first
    # Regex for Epic: ## Epic X: Title
    # Regex for Sprint: ### **Sprint X: Title (Optional Details)**
    # Regex for Microversion: ##### **vX.X.X.X - Title**
    # Regex for Task: - [x] **TX.X**: Description - **Effort**: X hours

    for line in md_content.splitlines():
        epic_match = re.match(r"^## (Epic \d+:.*)$", line)
        sprint_match = re.match(r"^### \*\*(Sprint \d+:.*?)(?:\(.*?\))?\*\*[:]?$", line) # Made (Weeks...) optional and non-capturing, added optional colon
        microversion_match = re.match(r"^##### \*\*v(\d+\.\d+\.\d+\.\d+[a-z]?) - (.*?)\*\*.*$", line) # Made title capture non-greedy
        task_match = re.match(r"^- \[(x| |✅)\] \*\*([A-Z]+\d+(?:\.\d+)*)\*\*: (.*?)(?: - \*\*Effort|\[Effort|\(Effort|Dependencies|Assignee|Granular Steps|Completion Notes|$)", line)


        if epic_match:
            if current_sprint: # An Epic or a previous Sprint was active
                sprints.append(current_sprint)
            current_sprint = {"title": epic_match.group(1).strip(), "microversions": []}
            current_microversion = None # Reset microversion when a new epic starts
        elif sprint_match:
            if current_sprint: # An Epic or a previous Sprint was active
                # If the current_sprint is an Epic, we don't append it yet,
                # this new sprint is conceptually part of it.
                # However, for the flat list structure, we close the previous sprint/epic.
                sprints.append(current_sprint)
            
            current_sprint = {"title": sprint_match.group(1).strip(), "microversions": []}
            current_microversion = None # Reset microversion when a new sprint starts
        elif microversion_match and current_sprint:
            if current_microversion: # Save previous microversion if exists
                current_sprint["microversions"].append(current_microversion)
            current_microversion = {"title": f"v{microversion_match.group(1)} - {microversion_match.group(2).strip()}", "tasks": []}
        elif task_match and current_microversion:
            status_char = task_match.group(1)
            status = "Complete" if status_char == 'x' or status_char == '✅' else "Open"
            task_id = task_match.group(2)
            description = task_match.group(3).strip()
            # Clean up description further if needed, the regex for task_match tries to stop before metadata
            current_microversion["tasks"].append({"id": task_id, "description": description, "status": status})

    # Append the last processed microversion and sprint
    if current_microversion and current_sprint:
        current_sprint["microversions"].append(current_microversion)
    if current_sprint:
        sprints.append(current_sprint)
    
    return sprints

def generate_html_report(sprints, output_path, css_path):
    # Corrected f-string for HTML content
    html_content = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Agile Sprint Status Report</title>
    <link rel="stylesheet" href="{os.path.relpath(css_path, os.path.dirname(output_path))}">
</head>
<body>
    <header>
        <h1>Adventure Jumper - Agile Sprint Status Report</h1>
        <p>Generated on: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
    </header>
    <main>
"""

    for sprint in sprints:
        if not sprint["microversions"] and not sprint.get("tasks"): # Skip if no microversions and no direct tasks (for Epics that might not have direct microversions)
            # Check if it's an Epic-like structure that might contain sprints (which are handled as separate items in the flat list)
            is_epic_title = sprint['title'].lower().startswith("epic")
            # If it's an epic and has no microversions, it might just be a container title, so skip direct rendering here.
            # Sprints under it would be separate items in the `sprints` list.
            if is_epic_title and not sprint["microversions"]:
                 # We could add a header for the Epic here if we change the structure to be nested.
                 # For a flat list, Epics without microversions of their own are just titles that precede their sprints.
                 # To avoid empty sections for Epics that only serve as titles for subsequent Sprints:
                pass # Continue to the next item, which might be a Sprint under this Epic.

        html_content += f'''<section class="sprint">
  <h2>{sprint['title']}</h2>
'''
        
        total_sprint_tasks = 0
        completed_sprint_tasks = 0

        # Handle tasks directly under a sprint/epic if any (though current parsing focuses on microversions)
        if sprint.get("tasks"): # Should not happen with current parsing logic but good for robustness
            direct_tasks = sprint.get("tasks", [])
            total_sprint_tasks += len(direct_tasks)
            completed_sprint_tasks += sum(1 for task in direct_tasks if task['status'] == 'Complete')
            if direct_tasks:
                html_content += "  <ul>\n"
                for task in direct_tasks:
                    status_class = 'task-complete' if task['status'] == 'Complete' else 'task-open'
                    html_content += f'''      <li class="{status_class}"><strong>{task['id']}</strong>: {task['description']}</li>
'''
                html_content += "  </ul>\n"


        for mv in sprint["microversions"]:
            html_content += f'''  <div class="microversion">
    <h3>{mv['title']}</h3>
'''
            
            total_mv_tasks = len(mv['tasks'])
            completed_mv_tasks = sum(1 for task in mv['tasks'] if task['status'] == 'Complete')
            
            # Add microversion tasks to sprint totals
            total_sprint_tasks += total_mv_tasks
            completed_sprint_tasks += completed_mv_tasks
            
            mv_progress = (completed_mv_tasks / total_mv_tasks * 100) if total_mv_tasks > 0 else 0
            
            html_content += f'''    <div class="progress-bar-container">
      <div class="progress-bar" style="width: {mv_progress}%;">{completed_mv_tasks}/{total_mv_tasks} ({mv_progress:.1f}%)</div>
    </div>
'''
            
            if mv['tasks']:
                html_content += "    <ul>\n"
                for task in mv['tasks']:
                    status_class = 'task-complete' if task['status'] == 'Complete' else 'task-open'
                    html_content += f'''      <li class="{status_class}"><strong>{task['id']}</strong>: {task['description']}</li>
'''
                html_content += "    </ul>\n"
            else:
                html_content += "    <p>No tasks defined for this microversion.</p>\n"
            html_content += "  </div>\n"

        sprint_progress = (completed_sprint_tasks / total_sprint_tasks * 100) if total_sprint_tasks > 0 else 0
        if total_sprint_tasks > 0: # Only show sprint summary if there are tasks
            html_content += f'''  <div class="sprint-summary progress-bar-container">
      <strong>Sprint Progress:</strong> <div class="progress-bar" style="width: {sprint_progress}%;">{completed_sprint_tasks}/{total_sprint_tasks} ({sprint_progress:.1f}%)</div>
  </div>
'''
        html_content += "</section>\n"
        
    html_content += """
    </main>
    <footer>
        <p>End of Report</p>
    </footer>
</body>
</html>"""
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(html_content)
    print(f"Report generated: {output_path}")

if __name__ == "__main__":
    script_dir = os.path.dirname(os.path.abspath(__file__))
    # Assuming the script is in 'adventure-jumper/scripts/'
    # and the markdown file is in 'adventure-jumper/docs/04_Project_Management/'
    workspace_root = os.path.abspath(os.path.join(script_dir, '..')) 

    markdown_file_path = os.path.join(workspace_root, "docs", "04_Project_Management", "AgileSprintPlan.md")
    output_html_path = os.path.join(workspace_root, "docs", "04_Project_Management", "sprint_status_report.html")
    # CSS is in the same directory as the script
    css_file_path = os.path.join(script_dir, "report_style.css") 

    if not os.path.exists(markdown_file_path):
        print(f"Error: Markdown file not found at {markdown_file_path}")
    else:
        with open(markdown_file_path, 'r', encoding='utf-8') as f:
            md_content = f.read()
        
        sprints_data = parse_markdown(md_content)
        generate_html_report(sprints_data, output_html_path, css_file_path)

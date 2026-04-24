import os
import re

def remove_comments(text):
    def replacer(match):
        s = match.group(0)
        if s.startswith('/'):
            return "" # it's a comment
        else:
            return s # it's a string

    pattern = re.compile(
        r'//.*?$|/\*.*?\*/|\'(?:\\\\.|[^\\\'])*\'|"(?:\\\\.|[^\\"])*"',
        re.DOTALL | re.MULTILINE
    )
    return re.sub(pattern, replacer, text)

def process_directory(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(('.dart', '.js', '.css', '.html')):
                path = os.path.join(root, file)
                try:
                    with open(path, 'r', encoding='utf-8') as f:
                        content = f.read()
                    
                    clean_content = remove_comments(content)
                    
                    # Remove multiple consecutive blank lines caused by comment removal
                    clean_content = re.sub(r'\n\s*\n\s*\n', '\n\n', clean_content)
                    
                    with open(path, 'w', encoding='utf-8') as f:
                        f.write(clean_content)
                    print(f"Cleaned: {path}")
                except Exception as e:
                    print(f"Error cleaning {path}: {e}")

if __name__ == "__main__":
    process_directory('lib')

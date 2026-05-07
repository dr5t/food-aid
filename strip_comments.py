import os
import re

def strip_comments(text):
    triple_double = r'"""[\s\S]*?"""'
    triple_single = r"'''[\s\S]*?'''"
    single_double = r'"(?:[^"\\]|\\.)*"'
    single_single = r"'(?:[^'\\]|\\.)*'"
    multi_comment = r'/\*[\s\S]*?\*/'
    single_comment = r'//[^\n]*'
    
    pattern = f'({triple_double}|{triple_single}|{single_double}|{single_single})|({multi_comment}|{single_comment})'
    
    def replacer(match):
        if match.group(2): 
            return ''
        else: 
            return match.group(1)
            
    return re.sub(pattern, replacer, text)

if __name__ == "__main__":
    count = 0
    target_dir = 'lib'
    for root, dirs, files in os.walk(target_dir):
        for file in files:
            if file.endswith('.dart'):
                path = os.path.join(root, file)
                try:
                    with open(path, 'r', encoding='utf-8') as f:
                        content = f.read()
                    
                    new_content = strip_comments(content)
                    
                    if new_content != content:
                        with open(path, 'w', encoding='utf-8') as f:
                            f.write(new_content)
                        count += 1
                except Exception as e:
                    print(f"Error on {path}: {e}")
    print(f"Stripped comments from {count} files.")

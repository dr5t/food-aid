import os
import sys

def validate_project():
    print("--- Project Validation Report ---")
    
    # 1. Check for key files
    key_files = [
        "pubspec.yaml",
        "lib/main.dart",
        "backend/index.php",
        "backend/analysis.py",
        "database/schema.sql",
        "firebase.json",
        ".gitignore"
    ]
    
    print("\n[1] Key Files Check:")
    for file_path in key_files:
        if os.path.exists(file_path):
            print(f"  [OK]  {file_path}")
        else:
            print(f"  [MISSING] {file_path}")

    # 2. Check file extensions in lib/
    print("\n[2] File Extension Check (lib/):")
    non_dart_in_lib = []
    for root, dirs, files in os.walk("lib"):
        for file in files:
            if not file.endswith(".dart"):
                non_dart_in_lib.append(os.path.join(root, file))
    
    if not non_dart_in_lib:
        print("  [OK] All files in lib/ have .dart extension.")
    else:
        for f in non_dart_in_lib:
            print(f"  [WARN] Non-dart file found: {f}")

    # 3. Check for PHP/Python/SQL in respective folders
    print("\n[3] Folder-specific Extension Check:")
    checks = {
        "backend": [".php", ".py"],
        "database": [".sql"],
        "web": [".html", ".js", ".css"]
    }
    
    for folder, allowed_exts in checks.items():
        if os.path.exists(folder):
            for root, dirs, files in os.walk(folder):
                for file in files:
                    ext = os.path.splitext(file)[1]
                    if ext not in allowed_exts and not file.startswith("."):
                        print(f"  [INFO] Found {ext} file in {folder}: {file}")

    # 4. Dependency Check
    print("\n[4] Dependency Configuration Check:")
    # Check pubspec.yaml for firebase
    if os.path.exists("pubspec.yaml"):
        with open("pubspec.yaml", "r") as f:
            content = f.read()
            if "firebase_core" in content:
                print("  [OK] Firebase dependencies found in pubspec.yaml")
            else:
                print("  [WARN] firebase_core not found in pubspec.yaml")
    
    # Check if build/web exists (from previous run)
    if os.path.exists("build/web"):
        print("  [OK] Web build artifacts found.")
    else:
        print("  [INFO] Web build artifacts not found (run flutter build web).")

if __name__ == "__main__":
    validate_project()

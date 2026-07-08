import os
import glob
import re

lib_dir = r"d:\TB WEB\tb_ecommerce\lib"
main_file = r"d:\TB WEB\tb_ecommerce\lib\main.dart"

# Rules for class names
class_replacements = {
    'EcommerceTheme': 'AppTheme',
    'EcommerceTextField': 'CustomTextField',
    'EcommercePrimaryButton': 'PrimaryButton',
    'Ecommerce': '',
}

# 1. Collect all files in lib
all_files = glob.glob(os.path.join(lib_dir, '**', '*.dart'), recursive=True)

# 2. Compute new file names and create rename mappings
file_renames = []
import_replacements = {}
for path in all_files:
    dir_name = os.path.dirname(path)
    base_name = os.path.basename(path)
    if 'ecommerce' in base_name:
        new_base_name = base_name.replace('ecommerce_', '').replace('_ecommerce', '')
        new_path = os.path.join(dir_name, new_base_name)
        file_renames.append((path, new_path))
        import_replacements[base_name] = new_base_name

# 3. Rename the files
for old_path, new_path in file_renames:
    os.rename(old_path, new_path)

# Update all_files to reflect new paths
all_files = glob.glob(os.path.join(lib_dir, '**', '*.dart'), recursive=True)

# 4. Modify file contents
for path in all_files:
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    new_content = content
    # Replace imports
    for old_import, new_import in import_replacements.items():
        new_content = new_content.replace(old_import, new_import)
    
    # Replace class names
    for old_class, new_class in class_replacements.items():
        # Match word boundaries for Ecommerce to avoid matching package:tb_ecommerce
        if old_class == 'Ecommerce':
            # Replace Ecommerce followed by a capital letter (e.g., EcommerceCartModel -> CartModel)
            # This is handled by regex
            new_content = re.sub(r'\bEcommerce([A-Z]\w*)', r'\1', new_content)
        else:
            new_content = re.sub(rf'\b{old_class}\b', new_class, new_content)

    if new_content != content:
        with open(path, 'w', encoding='utf-8') as f:
            f.write(new_content)

print(f"Renamed {len(file_renames)} files and updated contents.")

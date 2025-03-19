import subprocess
import re
import sys
from datetime import datetime

def extract_macros_via_clang(header):
    sdk_path = subprocess.run(
        ['xcrun', '--sdk', 'iphoneos', '--show-sdk-path'],
        capture_output=True, text=True
    ).stdout.strip()

    process = subprocess.run(
        [
            'xcrun', '--sdk', 'iphoneos', 'clang',
            '-isysroot', sdk_path,
            '-arch', 'arm64',
            '-dM', '-E', f'-include{header}', '-'
        ],
        input='',
        capture_output=True,
        text=True
    )

    macros = set()
    for line in process.stdout.splitlines():
        match = re.match(r'#define\s+([A-Za-z_][A-Za-z0-9_]*)\s+([^\s]+)', line)
        if match:
            name = match.group(1)
            value = match.group(2)
            if not name.startswith('__'):
                macros.add((name, value))
    return macros

def convert_to_js_octal(value):
    if value.startswith('0') and len(value) > 1:
        try:
        except ValueError:
    return value

def generate_js_file(macros, header_name):
    year = datetime.now().year
    output = []

    output.append(f'''// Generated JavaScript Constants for Macros from {header_name}
/*
 MIT License

 Copyright (c) {year} SeanIsTethered

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

''')

    for name, value in macros:
        value = convert_to_js_octal(value)
        output.append(f'const {name} = {value};')
    return '\n'.join(output)

def main():
    header = sys.argv[1]
    macros = extract_macros_via_clang(header)
    js_code = generate_js_file(macros, header)
    with open("macros.js", "w") as js_file:
        js_file.write(js_code)
    print("JavaScript file 'macros.js' generated successfully.")

if __name__ == "__main__":
    main()

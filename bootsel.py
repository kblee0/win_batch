import subprocess
import sys
import tkinter as tk
from tkinter import messagebox
import ctypes

def get_bcd_entries():
    result = subprocess.run(["bcdedit", "/v"], capture_output=True, text=True, shell=True)
    entries = []
    current_entry = {}
    for line in result.stdout.splitlines():
        line = line.strip()
        if line == "":
            if current_entry:
                entries.append(current_entry)
                current_entry = {}
        else:
            parts = line.strip().split(maxsplit=1)
            if len(parts) == 2:
                key, value = parts
                current_entry[key.strip()] = value.strip()
    if current_entry:
        entries.append(current_entry)
    return entries

def set_default_and_reboot(identifier):
    try:
        subprocess.run(["bcdedit", "/default", identifier], check=True, shell=True)
        subprocess.run(["shutdown", "/r", "/t", "0"], check=True, shell=True)
    except subprocess.CalledProcessError as e:
        messagebox.showerror("오류", f"작업 실패: {e}")

def on_select(event):
    selected = listbox.curselection()
    if not selected:
        return
    index = selected[0]
    identifier = identifiers[index]
    answer = messagebox.askyesno("확인", f"'{descriptions[index]}' 항목을 기본값으로 설정하고 재부팅할까요?")
    if answer:
        set_default_and_reboot(identifier)

# 관리자 권한 체크
def is_admin():
    try:
        return ctypes.windll.shell32.IsUserAnAdmin()
    except:
        return False

if not is_admin():
    messagebox.showerror("권한 오류", "이 프로그램은 관리자 권한으로 실행되어야 합니다.")
    sys.exit()

entries = get_bcd_entries()
identifiers = []
descriptions = []

for entry in entries:
    if "identifier" in entry and "timeout" not in entry:
        id = entry["identifier"]
        desc = entry.get("description", id)
        identifiers.append(id)
        descriptions.append(desc)

root = tk.Tk()
root.title("OS 부트 선택기")

label = tk.Label(root, text="부트 항목을 선택하세요:")
label.pack(pady=5)

listbox = tk.Listbox(root, width=50, height=10)
listbox.pack()

for desc in descriptions:
    listbox.insert(tk.END, "  " + desc)

listbox.bind('<<ListboxSelect>>', on_select)

root.update_idletasks()  # 실제 위젯 배치 후 창 크기 계산
width = root.winfo_width()
height = root.winfo_height()

screen_width = root.winfo_screenwidth()
screen_height = root.winfo_screenheight()

x = (screen_width // 2) - (width // 2)
y = (screen_height // 2) - (height // 2)

root.geometry(f"{width}x{height}+{x}+{y}")
root.resizable(False, False)

root.mainloop()

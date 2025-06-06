# 블루투스 마우스 듀얼OS 사용법..
How to pair a Low Energy (LE) Bluetooth device in dual boot with Windows & Linux
--------------------------------------------------------------------------------

##### Thursday, September 18, 2014

듀얼 부팅을 사용하는 분들은 다른 OS로 부팅할 때마다 키보드나 마우스를 다시 페어링해야 하는 번거로움을 잘 알고 계실 겁니다. 이 튜토리얼에서는 Windows 8과 Debian에서 LE 블루투스 마우스를 동시에 페어링하는 방법을 보여드리겠습니다.

먼저 데비안에서 기기를 페어링한 다음, 윈도우에서 재부팅하고 거기서도 기기를 페어링하세요. 네, 이렇게 하면 데비안의 페어링이 초기화됩니다. 그냥 계속 진행하세요. 이제 윈도우에서 페어링 키에 접근해야 합니다. [psexec.exe](http://live.sysinternals.com/psexec.exe)를 다운로드 한후 관리자 권한으로 명령 프롬프트를 엽니다.

```
> cd Downloads
> psexec.exe -s -i regedit /e C:\BTKeys.reg HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\BTHPORT\Parameters\Keys
```

이제 키가 `C:\BTKeys.reg`파일로 내보내졌을 것입니다. 파일의 내용은 아래처럼 나옵니다.

```
Windows Registry Editor Version 5.00
[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\BTHPORT\Parameters\Keys\7512a3185b2c\84abd4a25ee1]
"LTK"=hex:6c,54,ee,80,40,47,6c,cb,fc,8e,f3,f1,c6,b2,04,9e
"KeyLength"=dword:00000000
"ERand"=hex(b):1e,12,aa,37,39,cc,af,34
"EDIV"=dword:00003549
"CSRK"=hex:38,d7,aa,c1,42,06,31,25,12,b8,5a,6d,c3,90,98,f2
```

`7512a3185b2c` 는 Bluetooth 어댑터의 MAC 주소이며, 표준 형식으로도 `75:12:A3:18:5B:2C`로도 표기할 수 있습니다. `84abd4a25ee1` 는 페어링 과정에서 할당된 마우스 주소입니다. 다음 단계에서 이 번호가 필요합니다.

이제 데비안으로 다시 부팅해 보세요. 마우스가 자동으로 페어링되지 않습니다. 다른 주소와 다른 키에 할당되었기 때문입니다. 이 문제를 해결해 보겠습니다.

```
$ cd /var/lib/bluetooth/75:12:A3:18:5B:2C/
$ ls
cache 84:AB:D4:A2:5F:E1 settings

```

자세히 보면 마우스 주소가 Windows와 다릅니다. 제 경우에는 다섯 번째 그룹만 다릅니다. 장치 주소를 일치시켜야 하므로 파일 이름을 바꾸세요.

```
$ mv 84:AB:D4:A2:{5F,5E}:E1
$ cd 84:AB:D4:A2:5E:E1/
$ ls
attributes gatt info

```
이제  info 편집할 파일을 열고 키 값을 업데이트하세요. Windows 키 형식과 Bluetooth 키 형식의 관계는 다음과 같습니다.

*   `LTK`는 `LongTermKey`섹션의 `Key`값으로 설정합니다. 이때 대문자로 바꾸고 쉼표를 제거합니다.
*   `KeyLength`는 `EncSize`로 설정합니다. 제 경우에는 원래 값인 `12`를 `0`으로 바꿔야 했습니다.
*   `ERand`는 `Rand`로 변환됩니다. 이 부분이 까다롭습니다. 먼저 `ERand` 값을 역순으로 쓰면 `34afcc3937aa121e`가 됩니다. 그런 다음 10진수로 변환하면 `3796477557015712286`이 됩니다.
*   `EDIV`는 `EDiv`로 변환됩니다. 일반적으로 16진수에서 10진수로 변환하며, 이번에는 역변환이 없습니다.
*   `CSRK`는 `LocalSignatureKey` 그룹의 `Key`로 이동합니다. 대문자로 시작하고 쉼표는 사용하지 않습니다.

수정된 내용은 다음과 같습니다.

```
[LocalSignatureKey]
Key=38D7AAC14206312512B85A6DC39098F2
[LongTermKey]
Key=6C54EE8040476CCBFC8EF3F1C6B2049E
Authenticated=0
EncSize=0
EDiv=13641
Rand=3796477557015712286
```

변경 사항을 저장하고 재부팅하면 이제부터 데비안과 윈도우가 마우스를 자동으로 연결합니다.
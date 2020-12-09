# -*- mode: python ; coding: utf-8 -*-

block_cipher = None


a = Analysis(['bluephysics.py'],
             pathex=['/home/pi/model9'],
             binaries=[],
             datas=[('bluephysics.qml', '.'), ('bluephysics.qmlc', '.'), ('bpcntps-9.0_r0_sn003', './bpcntps-9.0_r0_sn003'), ('iconspd', './iconspd'), ('metadata.csv', '.'), ('rawdata', './rawdata')],
             hiddenimports=[],
             hookspath=[],
             runtime_hooks=[],
             excludes=[],
             win_no_prefer_redirects=False,
             win_private_assemblies=False,
             cipher=block_cipher,
             noarchive=False)
pyz = PYZ(a.pure, a.zipped_data,
             cipher=block_cipher)
exe = EXE(pyz,
          a.scripts,
          [],
          exclude_binaries=True,
          name='bluephysics',
          debug=False,
          bootloader_ignore_signals=False,
          strip=False,
          upx=True,
          console=True )
coll = COLLECT(exe,
               a.binaries,
               a.zipfiles,
               a.datas,
               strip=False,
               upx=True,
               upx_exclude=[],
               name='bluephysics')

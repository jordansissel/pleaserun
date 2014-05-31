package pleaserun

// This is a compile-time check, but we need to verify that Platform_SYSV
// satisfies the Platform interface.
var _ Platform = Platform_SYSV{}

func init() {
  registerPlatform("sysv", "", create)
}

type Platform_SYSV struct { 
  PlatformInfo
}

func create(name string, version string) Platform {
  p := Platform_SYSV{}
  p.PlatformInfo.Name = name
  p.PlatformInfo.Version = version
  return p
}

func (p Platform_SYSV) Name() string {
  return p.PlatformInfo.Name
}

func (p Platform_SYSV) Version() string {
  return p.PlatformInfo.Version
}

func (Platform_SYSV) Files(program Program) map[string][]byte { 
  return map[string][]byte {
    "/etc/init.d/{{Name()}}": []byte("world"),
  }
}
func (Platform_SYSV) Activation(program Program) []string { 
  return nil
}

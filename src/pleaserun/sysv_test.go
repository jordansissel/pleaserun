package pleaserun

import (
  "testing"
)

func TestRegistration(t *testing.T) {
  platform, err := NewPlatform("sysv", "whatever")
  if err != nil {
    t.Fatalf("Lookup for 'sysv' platform failed: %s\n", err)
  }
  if _, ok := platform.(Platform_SYSV); !ok {
    t.Fatal("Expected to get a Platform_SYSV from NewPlatform('sysv'...)")
  }

  if platform.Name() != "sysv" {
    t.Fatal("Expected Name() == 'sysv'")
  }
}


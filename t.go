package main

import (
	"encoding/json"

	"fmt"
	"github.com/Sirupsen/logrus"
	"net/rpc"
	"net/rpc/jsonrpc"
	"path"
	//"github.com/jessevdk/go-flags"
	"os"
	//"path"
	"io"
	"pleaserun"
)

var log = logrus.New()

func init() {
	log.Formatter = new(logrus.TextFormatter)
	pleaserun.SetLogger(log)
}

type Stdio struct {
	input  io.ReadCloser
	output io.WriteCloser
}

func (s Stdio) Read(p []byte) (int, error) {
	return s.input.Read(p)
}

func (s Stdio) Write(p []byte) (int, error) {
	return s.output.Write(p)
}

func (s Stdio) Close() (err error) {
	err = s.input.Close()
	if err != nil {
		s.output.Close() // Last resort to cleanup
		return
	}
	err = s.output.Close()
	return
}

type Please struct{}

type RunRequest struct {
	Program  pleaserun.Program `json:"program"`
	Platform string            `json:"platform"`
}
type Runner struct {
	Files          []pleaserun.File `json:"files"`
	InstallActions [][]string       `json:"install_actions"`
}

func (w *Please) Run(req RunRequest, rep *Runner) error {
	if len(req.Program.Program) == 0 {
		text, _ := json.Marshal(req.Program)
		return fmt.Errorf("Missing 'program' field in: %s", text)
	}
	if len(req.Program.Name) == 0 {
		_, req.Program.Name = path.Split(req.Program.Program)
	}
	search_path := []string{pleaserun.DefaultSearchPath(), "./platforms"}
	platform, err := pleaserun.FindPlatform(req.Platform, search_path)
	if err != nil {
		return fmt.Errorf("Failed to load platform '%s': %s", req.Platform, err)
	}

	files, err := pleaserun.Files(req.Program, *platform)
	if err != nil {
		return fmt.Errorf("Failed to generate files: %s", err)
	}

	*rep = Runner{Files: files, InstallActions: platform.InstallActions}

	return nil
}

func main() {
	log.Level = logrus.Debug

	stdio := &Stdio{input: os.Stdin, output: os.Stdout}

	server := rpc.NewServer()
	server.Register(new(Please))
	server.ServeCodec(jsonrpc.NewServerCodec(stdio))
	// If we get here, the server failed, probably due to codec problems.
}

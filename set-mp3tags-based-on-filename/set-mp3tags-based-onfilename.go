// "Script" to set certain mp3 tags based on the file name,
// this was only tested with audio files purchased and downloaded
// from hartdstyle.com

package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"path"
	"path/filepath"
	"regexp"
	"strconv"
)

func main() {
	r := regexp.MustCompile(`(?mi)(?P<tracknum>[0-9]{1,2}) (?P<artist>[a-z- ]+) - (?P<title>[a-z- ()]+)\.`)

	files, err := filepath.Glob("*.flac")
	if err != nil {
		log.Fatal(err)
	}

	cwd, err := os.Getwd()
	if err != nil {
		log.Fatal(err)
	}

	_, album := path.Split(cwd)

	for _, filename := range files {
		matches := r.FindStringSubmatch(filename)
		if matches == nil {
			continue
		}
		result := make(map[string]string)
		for i, name := range r.SubexpNames() {
			if i != 0 && name != "" {
				result[name] = matches[i]
			}
		}

		tracknum, err := strconv.Atoi(result["tracknum"])
		if err != nil {
			log.Fatal(err)
		}

		args := []string{
			fmt.Sprintf("--artist=%s", result["artist"]),
			fmt.Sprintf("--album=%s", album),
			fmt.Sprintf("--song=%s", result["title"]),
			fmt.Sprintf("--track=%d", tracknum),
			fmt.Sprintf("--total=%d", len(files)),
			filename,
		}

		fmt.Printf("id3tag %+v\n", args)

		cmd := exec.Command("id3tag", args...)
		out, err := cmd.CombinedOutput()
		if err != nil {
			log.Fatal(err)
		}
		fmt.Printf("%+q", out)
	}
}

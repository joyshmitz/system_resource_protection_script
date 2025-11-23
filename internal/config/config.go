package config

import (
	"flag"
	"os"
	"time"
)

// Config carries runtime options for sysmon.
type Config struct {
	Interval    time.Duration
	Sort        string
	Filter      string
	JSON        bool
	JSONStream  bool
	EnableGPU   bool
	EnableBatt  bool
}

func Default() Config {
	return Config{
		Interval:   time.Second,
		Sort:       "cpu",
		Filter:     "",
		JSON:       false,
		JSONStream: false,
		EnableGPU:  true,
		EnableBatt: true,
	}
}

// FromFlags parses flags and environment overrides.
func FromFlags(args []string) Config {
	cfg := Default()
	fs := flag.NewFlagSet("sysmon", flag.ContinueOnError)
	fs.DurationVar(&cfg.Interval, "interval", cfg.Interval, "refresh interval")
	fs.StringVar(&cfg.Sort, "sort", cfg.Sort, "sort column: cpu|mem")
	fs.StringVar(&cfg.Filter, "filter", cfg.Filter, "regex filter for process names")
	fs.BoolVar(&cfg.JSON, "json", cfg.JSON, "output one-shot JSON and exit")
	fs.BoolVar(&cfg.JSONStream, "json-stream", cfg.JSONStream, "stream NDJSON until interrupted")
	fs.BoolVar(&cfg.EnableGPU, "gpu", cfg.EnableGPU, "enable GPU sampling")
	fs.BoolVar(&cfg.EnableBatt, "battery", cfg.EnableBatt, "enable battery sampling")
	_ = fs.Parse(args)

	if v := os.Getenv("SRPS_SYSMON_INTERVAL"); v != "" {
		// Legacy env expects bare seconds; if user supplies a duration string, honor it.
		if parsed, err := time.ParseDuration(v); err == nil {
			cfg.Interval = parsed
		} else if parsed, err2 := time.ParseDuration(v + "s"); err2 == nil {
			cfg.Interval = parsed
		}
	}
	if v := os.Getenv("SRPS_SYSMON_GPU"); v == "0" {
		cfg.EnableGPU = false
	}
	if v := os.Getenv("SRPS_SYSMON_BATT"); v == "0" {
		cfg.EnableBatt = false
	}
	return cfg
}

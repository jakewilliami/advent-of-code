package main

import "time"

type DurationType int
type IntType int

const (
	PreciseDuration  DurationType = iota
	OverADayDuration DurationType = iota
	MissingDuration  DurationType = iota
)

const (
	ValidInt   IntType = iota
	MissingInt IntType = iota
)

type IntStat struct {
	Type  IntType
	Value int
}

type DurationStat struct {
	Type     DurationType
	Duration time.Duration
}

type DayPartStats struct {
	Year  IntStat
	Day   IntStat
	Time  DurationStat
	Rank  IntStat
	Score IntStat
}

type DayStats struct {
	Year  IntStat
	Day   IntStat
	Parts [2]DayPartStats
}

package main

import (
	"fmt"
	"golang.org/x/text/language"
	"golang.org/x/text/message"
	"os"

	"github.com/jedib0t/go-pretty/v6/table"
	"github.com/jedib0t/go-pretty/v6/text"
)

func (d DurationStat) String() string {
	switch d.Type {
	case MissingDuration:
		return fmt.Sprint("")
	case OverADayDuration:
		return fmt.Sprint("> 24h")
	case PreciseDuration:
		return fmt.Sprintf("%s", d.Duration) // TODO
	default:
		return fmt.Sprintf("Unhandled `IntStat' type %#v", d.Type)
	}
}

func (n IntStat) String() string {
	p := message.NewPrinter(language.English)
	switch n.Type {
	case MissingInt:
		return fmt.Sprint("")
	case ValidInt:
		return p.Sprintf("%d", n.Value)
	default:
		return fmt.Sprintf("Unhandled `IntStat' type %#v", n.Type)
	}
}

func makeStatsTable() table.Writer {
	rowConfig := table.RowConfig{AutoMerge: true}
	t := table.NewWriter()
	t.AppendHeader(table.Row{"", "", "Part 1", "Part 1", "Part 2", "Part 2"}, rowConfig)
	t.AppendHeader(table.Row{"Year", "Day", "Time", "Rank", "Time", "Rank"}, rowConfig)
	return t
}

func setTableOpts(t table.Writer) table.Writer {
	t.SetColumnConfigs([]table.ColumnConfig{
		{Number: 1, AutoMerge: true, VAlign: text.VAlignMiddle}, // Year
		{Number: 2, Align: text.AlignRight},                     // Day
		{Number: 3, Align: text.AlignCenter},                    // Time 1
		{Number: 4, Align: text.AlignRight},                     // Rank 1
		{Number: 5, Align: text.AlignCenter},                    // Time 2
		{Number: 6, Align: text.AlignRight},                     // Rank 2
	})
	t.SetOutputMirror(os.Stdout)
	t.SetStyle(table.StyleLight)
	t.Style().Format.Header = text.FormatDefault
	return t
}

func ShowStats(daystats map[int]DayStats) {
	t := makeStatsTable()
	for i := 1; i <= 25; i++ {
		day, exists := daystats[i]
		if exists {
			t.AppendRow(table.Row{
				day.Year.Value,
				day.Day.Value,
				day.Parts[0].Time,
				day.Parts[0].Rank,
				day.Parts[1].Time,
				day.Parts[1].Rank,
			})
		}
	}
	setTableOpts(t)
	t.Render()
}

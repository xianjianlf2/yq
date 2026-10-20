package yqlib

import "testing"

var emptyOperatorScenarios = []expressionScenario{
	{
		description: "Emit no values",
		document:    "{a: cat}",
		expression:  `empty`,
		expected:    []string{},
	},
	{
		description: "Skip missing values",
		document:    "[{name: cat}, {}, {name: dog}]",
		expression:  `[.[] | .name // empty]`,
		expected:    []string{"D0, P[], (!!seq)::- cat\n- dog\n"},
	},
	{
		description: "Omit values from an array",
		expression:  `[1, empty, 2]`,
		expected:    []string{"D0, P[], (!!seq)::- 1\n- 2\n"},
	},
	{
		skipDoc:    true,
		document:   "[1, 2]",
		expression: `map(empty)`,
		expected:   []string{"D0, P[], (!!seq)::[]\n"},
	},
	{
		skipDoc:    true,
		document:   "[null, false, 1, abc, {}, []]",
		expression: `.[] | empty`,
		expected:   []string{},
	},
	{
		skipDoc:    true,
		document:   "{empty: value}",
		expression: `.empty`,
		expected:   []string{"D0, P[empty], (!!str)::value\n"},
	},
}

func TestEmptyOperatorScenarios(t *testing.T) {
	for _, tt := range emptyOperatorScenarios {
		testScenario(t, &tt)
	}
	documentOperatorScenarios(t, "empty", emptyOperatorScenarios)
}

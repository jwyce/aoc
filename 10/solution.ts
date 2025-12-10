import { type Constraint, solve, type Model } from "yalps";

const input = await Bun.file(`${import.meta.dir}/input.txt`).text();
const lines = input.trim().split("\n");

// create bitmasks for lights and buttons so we can xor state
function parseLine(line: string) {
	const parts = line.split(" ");
	const lights = parts
		.at(0)!
		.slice(1, -1)
		.split("")
		.reduce((acc, l, i) => acc | ((l === "#" ? 1 : 0) << i), 0);
	const buttons = parts
		.slice(1, -1)
		.map((b) => b.slice(1, -1).split(",").map(Number));
	const buttonMasks = buttons.map((b) =>
		b.reduce((acc, n) => acc | (1 << +n), 0),
	);
	const joltages = parts.at(-1)!.slice(1, -1).split(",").map(Number);

	return { lights, buttons, buttonMasks, joltages };
}

// bfs state -> min presses to reach from 0
function minPresses(target: number, buttons: number[]) {
	const memo = new Map<number, number>([[0, 0]]);
	const queue = [0];
	let head = 0;

	while (head < queue.length) {
		const state = queue[head++];
		if (state === target) return memo.get(state)!;

		for (const btn of buttons) {
			const next = state ^ btn;
			if (!memo.has(next)) {
				memo.set(next, memo.get(state)! + 1);
				queue.push(next);
			}
		}
	}

	return -1;
}

// integer linear programming
// joltages create a system of linear equations
// we need to find press counts such that:
// x1*btn1 + x2*btn2 ... xn*btn = joltage_target
function minPressesILP(buttons: number[][], joltages: number[]) {
	const variables: Record<string, Record<string, number>> = {};
	const constraints: Record<string, Constraint> = {};

	// each button is a variable
	for (let b = 0; b < buttons.length; b++) {
		const effect: Record<string, number> = { presses: 1 };
		for (const i of buttons[b]) {
			effect[`c${i}`] = 1;
		}

		variables[`x${b}`] = effect;
	}

	// each counter must hit exact target
	for (let i = 0; i < joltages.length; i++) {
		constraints[`c${i}`] = { equal: joltages[i] };
	}

	const model: Model = {
		direction: "minimize",
		objective: "presses",
		constraints,
		variables,
		integers: Object.keys(variables),
	};

	const result = solve(model);
	return result.status === "optimal" ? Math.round(result.result) : -1;
}

function part1() {
	return lines.reduce((sum, line) => {
		const { lights, buttonMasks } = parseLine(line);
		return sum + minPresses(lights, buttonMasks);
	}, 0);
}

function part2() {
	return lines.reduce((sum, line) => {
		const { joltages, buttons } = parseLine(line);
		return sum + minPressesILP(buttons, joltages);
	}, 0);
}

console.log("Part 1:", part1());
console.log("Part 2:", part2());

const input = await Bun.file(`${import.meta.dir}/input.txt`).text();
const lines = input.trim().split("\n");

function transpose<T>(matrix: T[][]) {
	const transposed: T[][] = Array.from({ length: matrix[0].length }, () =>
		Array(matrix.length).fill(undefined),
	);

	for (let y = 0; y < matrix.length; y++) {
		for (let x = 0; x < matrix[0].length; x++) {
			transposed[x][y] = matrix[y][x];
		}
	}

	return transposed;
}

type Operation = "*" | "+";
function solve(operands: number[], op: Operation) {
	if (op === "*") {
		return operands.reduce((acc, x) => acc * x, 1);
	}

	if (op === "+") {
		return operands.reduce((acc, x) => acc + x, 0);
	}

	return 0;
}

function part1() {
	const normalizedInput = lines.map((l) =>
		l
			.replace(/\p{White_Space}+/gu, " ")
			.trim()
			.split(" "),
	);
	const ops = normalizedInput[normalizedInput.length - 1] as Operation[];
	const problems = normalizedInput.slice(0, -1).map((arg) => arg.map(Number));
	let total = 0;

	for (const [idx, operands] of transpose(problems).entries()) {
		total += solve(operands, ops[idx]);
	}

	return total;
}

function part2() {
	const ops = lines[lines.length - 1]
		.replace(/\p{White_Space}+/gu, " ")
		.split(" ") as Operation[];

	const padLen = Math.max(...lines.map((l) => l.length));
	const padded = lines.slice(0, -1).map((l) => l.padEnd(padLen, " ").split(""));

	const problems = transpose(padded)
		.map((x) => (x.every((y) => y === " ") ? "|" : +x.join("").trim()))
		.join()
		.split("|")
		.map((g) => g.split(",").filter(Boolean).map(Number));

	let total = 0;

	for (const [idx, operands] of problems.entries()) {
		total += solve(operands, ops[idx]);
	}

	return total;
}

console.log("Part 1:", part1());
console.log("Part 2:", part2());

const input = await Bun.file(`${import.meta.dir}/input.txt`).text();
const lines = input.trim().split("\n");

type Point = { x: number; y: number };

function neighbors(grid: string[][], { x, y }: Point) {
	return [
		{ x: x - 1, y },
		{ x: x + 1, y },
		{ x: x - 1, y: y + 1 },
		{ x: x + 1, y: y + 1 },
		{ x: x - 1, y: y - 1 },
		{ x: x + 1, y: y - 1 },
		{ x: x, y: y + 1 },
		{ x: x, y: y - 1 },
	].filter(
		(p) => p.x >= 0 && p.x < grid.length && p.y >= 0 && p.y < grid[0].length,
	);
}

function removeRolls(grid: string[][], points: Point[]) {
	const newGrid = structuredClone(grid);

	for (const p of points) {
		newGrid[p.x][p.y] = ".";
	}

	return newGrid;
}

function part1() {
	let sum = 0;
	const grid = lines.map((l) => l.split(""));

	for (let y = 0; y < grid.length; y++) {
		for (let x = 0; x < grid[0].length; x++) {
			const cell = grid[x][y];
			if (cell === "@") {
				const rolls = neighbors(grid, { x, y })
					.map((n) => grid[n.x][n.y])
					.filter((x) => x === "@").length;

				if (rolls < 4) {
					sum++;
				}
			}
		}
	}

	return sum;
}

function part2() {
	let sum = 0;
	let grid = lines.map((l) => l.split(""));
	let stillRemoving = true;
	let accessible: Point[] = [];

	while (stillRemoving) {
		for (let y = 0; y < grid.length; y++) {
			for (let x = 0; x < grid[0].length; x++) {
				const cell = grid[x][y];
				if (cell === "@") {
					const rolls = neighbors(grid, { x, y })
						.map((n) => grid[n.x][n.y])
						.filter((x) => x === "@").length;

					if (rolls < 4) {
						accessible.push({ x, y });
					}
				}
			}
		}

		if (accessible.length === 0) stillRemoving = false;
		if (accessible.length > 0) {
			sum += accessible.length;
			grid = removeRolls(grid, accessible);
			accessible = [];
		}
	}

	return sum;
}

console.log("Part 1:", part1());
console.log("Part 2:", part2());

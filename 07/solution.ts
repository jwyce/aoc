const input = await Bun.file(`${import.meta.dir}/input.txt`).text();
const lines = input.trim().split("\n");

type Point = { x: number; y: number };

function neighbors(grid: string[][], { x, y }: Point) {
	const cell = grid[y][x];
	const deltaMap: Record<string, [number, number][]> = {
		S: [[0, 1]],
		".": [[0, 1]],
		"^": [
			[1, 1],
			[-1, 1],
		],
	};
	const deltas = deltaMap[cell] ?? [];

	return deltas
		.map(([dx, dy]) => ({ x: x + dx, y: y + dy }))
		.filter(
			(n) => n.x >= 0 && n.x < grid[0].length && n.y >= 0 && n.y < grid.length,
		);
}

const toKey = (p: Point) => `(${p.x},${p.y})`;

function bfs(grid: string[][], start: Point) {
	const splitters = new Set<string>();
	const queue: Point[] = [start];
	const visited = new Set<string>();
	visited.add(toKey(start));

	while (queue.length > 0) {
		// biome-ignore lint/style/noNonNullAssertion: always guaranteed to exist
		const current = queue.shift()!;
		const ns = neighbors(grid, current);
		if (ns.length === 2) {
			splitters.add(toKey(current));
		}

		for (const neighbor of ns) {
			if (!visited.has(toKey(neighbor))) {
				visited.add(toKey(neighbor));
				queue.push(neighbor);
			}
		}
	}

	return splitters.size;
}

function countPaths(grid: string[][], start: Point) {
	const memo = new Map<string, number>();

	function dfs(pos: Point): number {
		const key = toKey(pos);
		// biome-ignore lint/style/noNonNullAssertion: we just check it has it
		if (memo.has(key)) return memo.get(key)!;

		const ns = neighbors(grid, pos);
		if (ns.length === 0) return 1;

		const count = ns.reduce((sum, n) => sum + dfs(n), 0);
		memo.set(key, count);
		return count;
	}

	return dfs(start);
}

function part1() {
	const grid = lines.map((l) => l.split(""));
	const start = { x: grid[0].findIndex((p) => p === "S"), y: 0 };
	return bfs(grid, start);
}

function part2() {
	const grid = lines.map((l) => l.split(""));
	const start = { x: grid[0].findIndex((p) => p === "S"), y: 0 };
	return countPaths(grid, start);
}

console.log("Part 1:", part1());
console.log("Part 2:", part2());

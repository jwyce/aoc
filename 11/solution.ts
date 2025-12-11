const input = await Bun.file(`${import.meta.dir}/input.txt`).text();
const lines = input.trim().split("\n");

function parseGraph(lines: string[]) {
	const g = new Map<string, string[]>();

	for (const line of lines) {
		const [node, neighbors] = line.split(":");
		g.set(node, neighbors.trim().split(" "));
	}

	return g;
}

function countPaths(grid: Map<string, string[]>, start: string) {
	const memo = new Map<string, number>();

	function dfs(device: string): number {
		if (memo.has(device)) return memo.get(device)!;

		const neighbors = grid.get(device);
		if (!neighbors) return 1;

		const count = neighbors.reduce((sum, n) => sum + dfs(n), 0);
		memo.set(device, count);
		return count;
	}

	return dfs(start);
}

function countPaths2(grid: Map<string, string[]>, start: string) {
	// key: "device|visitedDac|visitedFft"
	const memo = new Map<string, number>();

	function dfs(device: string, hasDac: boolean, hasFft: boolean): number {
		const seenDac = hasDac || device === "dac";
		const seenFft = hasFft || device === "fft";

		if (device === "out") {
			return seenDac && seenFft ? 1 : 0;
		}

		const key = `${device}|${seenDac}|${seenFft}`;
		if (memo.has(key)) return memo.get(key)!;

		const neighbors = grid.get(device);
		// dead end, not "out"
		if (!neighbors) return 0;

		const count = neighbors.reduce(
			(sum, n) => sum + dfs(n, seenDac, seenFft),
			0,
		);
		memo.set(key, count);
		return count;
	}

	return dfs(start, false, false);
}

function part1() {
	return countPaths(parseGraph(lines), "you");
}

function part2() {
	return countPaths2(parseGraph(lines), "svr");
}

console.log("Part 1:", part1());
console.log("Part 2:", part2());

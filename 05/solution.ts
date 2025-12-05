const input = await Bun.file(`${import.meta.dir}/input.txt`).text();
const [rangeStr, dataStr] = input
	.trim()
	.split("\n\n")
	.map((x) => x.split("\n"));

function inRange(r: number[], d: number) {
	const [min, max] = r;
	return d >= min && d <= max;
}

function part1() {
	const ranges = rangeStr.map((r) => r.split("-").map(Number));
	const data = dataStr.map(Number);
	let count = 0;

	for (const d of data) {
		if (ranges.some((r) => inRange(r, d))) {
			count++;
		}
	}

	return count;
}

function reduceRanges(ranges: number[][]) {
	// any pair of ranges whose end of one and start of the other is one apart can be replaced with a single range
	const sorted = [...ranges].sort((a, b) => a[0] - b[0]);
	const result: number[][] = [];

	for (const [start, end] of sorted) {
		const last = result.at(-1);
		if (last && start <= last[1] + 1) {
			last[1] = Math.max(last[1], end);
		} else {
			result.push([start, end]);
		}
	}

	return result;
}

// do a pass where I simplify the overlapping ranges so there are none overlapping
// then simply do a sum of differences of each range
function part2() {
	const ranges = rangeStr.map((r) => r.split("-").map(Number));
	const nonOverlapping: number[][] = reduceRanges(ranges);
	let sum = 0;

	for (const [start, end] of nonOverlapping) {
		sum += end - start + 1;
	}

	return sum;
}

console.log("Part 1:", part1());
console.log("Part 2:", part2());

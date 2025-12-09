const input = await Bun.file(`${import.meta.dir}/input.txt`).text();
const lines = input.trim().split("\n");

// brute force
function part1() {
	const points = lines.map((l) => l.split(",").map(Number));
	const areas: number[] = [];

	for (let i = 0; i < points.length; i++) {
		for (let k = i; k < points.length; k++) {
			const [ax, ay] = points[i];
			const [bx, by] = points[k];
			areas.push((Math.abs(ax - bx) + 1) * (Math.abs(ay - by) + 1));
		}
	}

	return Math.max(...areas);
}

function isInsideOrOnBoundary(
	polygon: number[][],
	px: number,
	py: number,
): boolean {
	let crossings = 0;

	for (let i = 0; i < polygon.length; i++) {
		const [x1, y1] = polygon[i];
		const [x2, y2] = polygon[(i + 1) % polygon.length];

		// on vertical edge?
		if (
			x1 === x2 &&
			px === x1 &&
			py >= Math.min(y1, y2) &&
			py <= Math.max(y1, y2)
		)
			return true;
		// on horizontal edge?
		if (
			y1 === y2 &&
			py === y1 &&
			px >= Math.min(x1, x2) &&
			px <= Math.max(x1, x2)
		)
			return true;
		// ray casting (vertical edges only)
		if (x1 === x2 && x1 > px && py > Math.min(y1, y2) && py <= Math.max(y1, y2))
			crossings++;
	}

	return crossings % 2 === 1;
}

function rectangleFullyInside(
	polygon: number[][],
	ax: number,
	ay: number,
	bx: number,
	by: number,
): boolean {
	const minX = Math.min(ax, bx);
	const maxX = Math.max(ax, bx);
	const minY = Math.min(ay, by);
	const maxY = Math.max(ay, by);

	// check other 2 corners are inside
	if (!isInsideOrOnBoundary(polygon, minX, maxY)) return false;
	if (!isInsideOrOnBoundary(polygon, maxX, minY)) return false;

	// check no edge cuts through
	for (let i = 0; i < polygon.length; i++) {
		const [x1, y1] = polygon[i];
		const [x2, y2] = polygon[(i + 1) % polygon.length];

		// horizontal edge cuts through?
		if (
			y1 === y2 &&
			y1 > minY &&
			y1 < maxY &&
			Math.min(x1, x2) < maxX &&
			Math.max(x1, x2) > minX
		)
			return false;
		// vertical edge cuts through?
		if (
			x1 === x2 &&
			x1 > minX &&
			x1 < maxX &&
			Math.min(y1, y2) < maxY &&
			Math.max(y1, y2) > minY
		)
			return false;
	}

	return true;
}

function part2() {
	const points = lines.map((l) => l.split(",").map(Number));
	const areas: number[] = [];

	for (let i = 0; i < points.length; i++) {
		for (let k = i + 1; k < points.length; k++) {
			const [ax, ay] = points[i];
			const [bx, by] = points[k];

			if (rectangleFullyInside(points, ax, ay, bx, by)) {
				areas.push((Math.abs(ax - bx) + 1) * (Math.abs(ay - by) + 1));
			}
		}
	}

	return Math.max(...areas);
}

console.log("Part 1:", part1());
console.log("Part 2:", part2());

const input = await Bun.file(`${import.meta.dir}/input.txt`).text();

type Shape = [number, number][];

function parse(input: string) {
	const blocks = input.trim().split("\n\n");
	const shapes: Shape[] = [];
	const regions: { width: number; height: number; counts: number[] }[] = [];

	for (const block of blocks) {
		const lines = block.split("\n");
		const firstLine = lines[0];

		if (firstLine.endsWith(":") && !firstLine.includes("x")) {
			const cells: Shape = [];
			for (let r = 1; r < lines.length; r++) {
				for (let c = 0; c < lines[r].length; c++) {
					if (lines[r][c] === "#") cells.push([r - 1, c]);
				}
			}
			shapes.push(cells);
		} else if (firstLine.includes("x")) {
			for (const line of lines) {
				const [dims, rest] = line.split(": ");
				const [w, h] = dims.split("x").map(Number);
				regions.push({
					width: w,
					height: h,
					counts: rest.split(" ").map(Number),
				});
			}
		}
	}

	return { shapes, regions };
}

function orientations(shape: Shape): Shape[] {
	const seen = new Set<string>();
	const results: Shape[] = [];
	const transforms = [
		([r, c]: [number, number]) => [r, c],
		([r, c]: [number, number]) => [c, -r],
		([r, c]: [number, number]) => [-r, -c],
		([r, c]: [number, number]) => [-c, r],
		([r, c]: [number, number]) => [r, -c],
		([r, c]: [number, number]) => [-r, c],
		([r, c]: [number, number]) => [c, r],
		([r, c]: [number, number]) => [-c, -r],
	] as const;

	for (const t of transforms) {
		const transformed = shape.map(t);
		const minR = Math.min(...transformed.map(([r]) => r));
		const minC = Math.min(...transformed.map(([, c]) => c));
		const normalized: Shape = transformed
			.map(([r, c]) => [r - minR, c - minC] as [number, number])
			.sort((a, b) => a[0] - b[0] || a[1] - b[1]);

		const key = JSON.stringify(normalized);
		if (!seen.has(key)) {
			seen.add(key);
			results.push(normalized);
		}
	}

	return results;
}

function fits(
	grid: boolean[][],
	shape: Shape,
	r: number,
	c: number,
	h: number,
	w: number,
) {
	for (const [dr, dc] of shape) {
		const nr = r + dr;
		const nc = c + dc;
		if (nr < 0 || nr >= h || nc < 0 || nc >= w || grid[nr][nc]) return false;
	}
	return true;
}

function place(
	grid: boolean[][],
	shape: Shape,
	r: number,
	c: number,
	val: boolean,
) {
	for (const [dr, dc] of shape) {
		grid[r + dr][c + dc] = val;
	}
}

function canPlace(
	grid: boolean[][],
	pieces: Shape[][],
	remaining: number[],
	h: number,
	w: number,
): boolean {
	if (remaining.every((r) => r === 0)) return true;

	for (let i = 0; i < pieces.length; i++) {
		if (remaining[i] === 0) continue;

		for (const orient of pieces[i]) {
			for (let r = 0; r < h; r++) {
				for (let c = 0; c < w; c++) {
					if (fits(grid, orient, r, c, h, w)) {
						place(grid, orient, r, c, true);
						remaining[i]--;
						if (canPlace(grid, pieces, remaining, h, w)) return true;
						remaining[i]++;
						place(grid, orient, r, c, false);
					}
				}
			}
		}
		break; // only try first piece type with remaining > 0
	}
	return false;
}

function solve(
	shapes: Shape[],
	width: number,
	height: number,
	counts: number[],
) {
	const totalCells = counts.reduce(
		(sum, c, i) => sum + c * shapes[i].length,
		0,
	);
	if (totalCells > width * height) return false;

	const grid = Array.from({ length: height }, () => Array(width).fill(false));
	return canPlace(grid, shapes.map(orientations), [...counts], height, width);
}

function part1() {
	const { shapes, regions } = parse(input);
	return regions.filter((r) => solve(shapes, r.width, r.height, r.counts))
		.length;
}

console.log("Part 1:", part1());

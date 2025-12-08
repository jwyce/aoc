import * as mnemonist from "mnemonist";

const input = await Bun.file(`${import.meta.dir}/input.txt`).text();
const lines = input.trim().split("\n");

class UnionFind {
	#parent = new Map<string, string>();
	#groups = new Map<string, Vec3[]>();
	#vecMap = new Map<string, Vec3>(); // key -> original vec3

	constructor() {
		this.#parent = new Map<string, string>();
		this.#groups = new Map<string, Vec3[]>();
		this.#vecMap = new Map<string, Vec3>();
	}

	#key(v: Vec3): string {
		return `${v.x},${v.y},${v.z}`;
	}

	find(v: Vec3): string {
		const k = this.#key(v);
		if (!this.#parent.has(k)) {
			this.#parent.set(k, k);
			this.#groups.set(k, [v]);
			this.#vecMap.set(k, v);
		}
		if (this.#parent.get(k) !== k) {
			this.#parent.set(k, this.find(this.#vecMap.get(this.#parent.get(k)!)!));
		}
		return this.#parent.get(k)!;
	}

	union(a: Vec3, b: Vec3): void {
		const rootA = this.find(a);
		const rootB = this.find(b);
		if (rootA !== rootB) {
			this.#parent.set(rootB, rootA);
			this.#groups.get(rootA)!.push(...this.#groups.get(rootB)!);
			this.#groups.delete(rootB);
		}
	}

	getGroup(v: Vec3): Vec3[] {
		return this.#groups.get(this.find(v))!;
	}

	getAllGroups(): Vec3[][] {
		return [...this.#groups.values()];
	}
}

type Vec3 = { x: number; y: number; z: number };
type Node = { dist: number; pair: Vec3[] };

function dist(a: Vec3, b: Vec3) {
	return Math.sqrt((a.x - b.x) ** 2 + (a.y - b.y) ** 2 + (a.z - b.z) ** 2);
}

function toVec3(arr: number[]) {
	if (arr.length !== 3) throw new Error("bad input");
	return { x: arr[0], y: arr[1], z: arr[2] };
}

// make the 1000 (test: 10) shortest pair-wise connections and count circuit groups
// build min heap on pair-wise distances and extract min
// then implement a dynamic union-find to build groups
function part1() {
	const nsmallest = 1000;
	const points = lines.map((l) => l.split(",").map(Number)).map(toVec3);
	const heap = new mnemonist.MinHeap<Node>((a, b) => a.dist - b.dist);
	const uf = new UnionFind();

	for (const p of points) {
		uf.find(p);
	}

	// all pairs
	for (let i = 0; i < points.length; i++) {
		for (let k = i + 1; k < points.length; k++) {
			const [a, b] = [points[i], points[k]];
			const d = dist(a, b);
			heap.push({ dist: d, pair: [a, b] });
		}
	}

	for (let i = 0; i < nsmallest; i++) {
		const node = heap.pop()!;
		const [a, b] = node.pair;
		uf.union(a, b);
	}

	const largest3 = uf
		.getAllGroups()
		.sort((a, b) => b.length - a.length)
		.slice(0, 3);

	return largest3.reduce((acc, g) => acc * g.length, 1);
}

// find when the MST (minimum spanning tree) becomes fully connected
function part2() {
	const points = lines.map((l) => l.split(",").map(Number)).map(toVec3);
	const heap = new mnemonist.MinHeap<Node>((a, b) => a.dist - b.dist);
	const uf = new UnionFind();

	for (const p of points) {
		uf.find(p);
	}

	// build heap with all pairs
	for (let i = 0; i < points.length; i++) {
		for (let k = i + 1; k < points.length; k++) {
			const [a, b] = [points[i], points[k]];
			const d = dist(a, b);
			heap.push({ dist: d, pair: [a, b] });
		}
	}

	while (uf.getAllGroups().length > 1) {
		const node = heap.pop()!;
		const [a, b] = node.pair;

		if (uf.find(a) !== uf.find(b)) {
			uf.union(a, b);

			// last pair to create 1 circuit
			if (uf.getAllGroups().length === 1) {
				return a.x * b.x;
			}
		}
	}

	return 0;
}

console.log("Part 1:", part1());
console.log("Part 2:", part2());

const day = process.argv[2];

if (!day) {
	console.error("Usage: bun run day <day>");
	console.error("Example: bun run day 1");
	process.exit(1);
}

const dayNum = Number.parseInt(day, 10);
if (Number.isNaN(dayNum) || dayNum < 1 || dayNum > 25) {
	console.error("Day must be a number between 1 and 25");
	process.exit(1);
}

const dayStr = dayNum.toString().padStart(2, "0");
const tsPath = `${import.meta.dir}/../${dayStr}/solution.ts`;

const file = Bun.file(tsPath);
if (!(await file.exists())) {
	console.error(`Day ${dayNum} not found. Run 'bun run get ${dayNum}' first.`);
	process.exit(1);
}

await import(tsPath);

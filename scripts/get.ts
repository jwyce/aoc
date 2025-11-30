async function main() {
	const arg = process.argv[2];

	// Default to today's date in December
	const today = new Date();
	const defaultDay = today.getMonth() === 11 ? today.getDate() : 1;
	const dayNum = arg ? Number.parseInt(arg, 10) : defaultDay;

	if (Number.isNaN(dayNum) || dayNum < 1 || dayNum > 25) {
		console.error("Day must be a number between 1 and 25");
		process.exit(1);
	}

	const dayStr = dayNum.toString().padStart(2, "0");
	const dayDir = `${import.meta.dir}/../${dayStr}`;

	const { AOC_COOKIE, AOC_REPO, AOC_CONTACT } = process.env;

	if (!AOC_COOKIE || !AOC_REPO || !AOC_CONTACT) {
		console.error("Missing required environment variables:");
		console.error("  AOC_COOKIE - Your session cookie from adventofcode.com");
		console.error("  AOC_REPO   - Your repository URL");
		console.error("  AOC_CONTACT - Your contact email");
		process.exit(1);
	}

	// Create day directory
	await Bun.write(`${dayDir}/.keep`, "");

	// Fetch input
	const year = 2024;
	const inputUrl = `https://adventofcode.com/${year}/day/${dayNum}/input`;

	console.log(`🎄 Fetching input for day ${dayNum}...`);

	const response = await fetch(inputUrl, {
		headers: {
			Cookie: AOC_COOKIE,
			"User-Agent": `${AOC_REPO} by ${AOC_CONTACT}`,
		},
	});

	if (!response.ok) {
		console.error(
			`Failed to fetch input: ${response.status} ${response.statusText}`,
		);
		const text = await response.text();
		console.error(text);
		process.exit(1);
	}

	const input = await response.text();
	await Bun.write(`${dayDir}/input.txt`, input);
	console.log(`📥 Saved input to ${dayStr}/input.txt`);

	// Create index.ts template
	const tsTemplate = `const input = await Bun.file(\`\${import.meta.dir}/input.txt\`).text();
const lines = input.trim().split("\\n");

function part1() {
	// TODO: Implement part 1
	return 0;
}

function part2() {
	// TODO: Implement part 2
	return 0;
}

console.log("Part 1:", part1());
console.log("Part 2:", part2());
`;

	const indexPath = `${dayDir}/index.ts`;
	const indexFile = Bun.file(indexPath);

	if (await indexFile.exists()) {
		console.log(`${dayStr}/index.ts already exists, skipping...`);
	} else {
		await Bun.write(indexPath, tsTemplate);
		console.log(`🥟 Created ${dayStr}/index.ts`);
	}

	// Create OCaml solution.ml template
	const mlTemplate = `let read_input () =
  let ic = open_in "input.txt" in
  let rec read_lines acc =
    try
      let line = input_line ic in
      read_lines (line :: acc)
    with End_of_file ->
      close_in ic;
      List.rev acc
  in
  read_lines []

let part1 _lines = 0

let part2 _lines = 0

let () =
  let lines = read_input () in
  Printf.printf "Part 1: %d\\n" (part1 lines);
  Printf.printf "Part 2: %d\\n" (part2 lines)
`;

	const mlPath = `${dayDir}/solution.ml`;
	const mlFile = Bun.file(mlPath);

	if (await mlFile.exists()) {
		console.log(`${dayStr}/solution.ml already exists, skipping...`);
	} else {
		await Bun.write(mlPath, mlTemplate);
		console.log(`🐫 Created ${dayStr}/solution.ml`);
	}

	// Create dune file
	const duneTemplate = `(executable
 (name solution))
`;

	const dunePath = `${dayDir}/dune`;
	const duneFile = Bun.file(dunePath);

	if (await duneFile.exists()) {
		console.log(`${dayStr}/dune already exists, skipping...`);
	} else {
		await Bun.write(dunePath, duneTemplate);
		console.log(`🏜️ Created ${dayStr}/dune`);
	}

	// Clean up .keep file
	await Bun.file(`${dayDir}/.keep`).delete();

	console.log('\nReady! Run with:');
	console.log(`  bun run day ${dayNum}`);
	console.log(`  dune exec ./${dayStr}/solution.exe`);
}

main();

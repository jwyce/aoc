const input = await Bun.file(`${import.meta.dir}/input.txt`).text();
const lines = input.trim().split("\n");

// brute force
function part1() {
	let sum = 0;

	for (const line of lines) {
		const bank = line.split("").map((x) => Number.parseInt(x));
		let highestJoltage = 0;

		for (let a = 0; a < bank.length; a++) {
			for (let b = a + 1; b < bank.length; b++) {
				const j = Number.parseInt(`${bank[a]}${bank[b]}`);
				highestJoltage = Math.max(highestJoltage, j);
			}
		}

		sum += highestJoltage;
	}

	return sum;
}

// greedy pick largest digit while I have room
function part2() {
	let sum = 0;

	for (const line of lines) {
		const bank = line.split("").map((x) => Number.parseInt(x));
		let highestJoltage = "";
		let start = 0;

		while (highestJoltage.length < 12) {
			const remaining = 12 - highestJoltage.length;
			const end = bank.length - remaining;
			let highest = { j: 0, i: start };

			for (let i = start; i <= end; i++) {
				if (bank[i] > highest.j) {
					highest = { j: bank[i], i };
				}
			}

			highestJoltage += `${highest.j}`;
			start = highest.i + 1;
		}

		sum += Number.parseInt(highestJoltage);
	}

	return sum;
}

console.log("Part 1:", part1());
console.log("Part 2:", part2());

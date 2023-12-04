export const x = "";
const input = await Deno.readTextFile("./input.txt");

type Card = {
  id: number;
  winning: number[];
  yours: number[];
};

const cards: Card[] = input.split("\n").map((x, i) => {
  const [_, nums] = x.split(":");
  if (!nums) return { id: i + 1, winning: [], yours: [] };

  const [w, y] = nums.trim().split("|");
  return {
    id: i + 1,
    winning: w.trim().split(" ").map((x) => parseInt(x)).filter((x) =>
      !isNaN(x)
    ),
    yours: y.trim().split(" ").map((x) => parseInt(x)).filter((x) => !isNaN(x)),
  };
});

cards.pop();

let output = 0;

const matches: Record<number, number[]> = {};
const counts: Record<number, number> = {};

cards.forEach((card, idx) => {
  let count = 0;

  card.yours.forEach((y) => {
    if (card.winning.includes(y)) {
      count++;
    }
  });

  for (let i = idx + 2; i < count + idx + 2; i++) {
    if (matches[card.id] === undefined) {
      matches[card.id] = [i];
    } else {
      matches[card.id].push(i);
    }

    const multiplier = (counts[idx + 1] ?? 0) + 1;

    if (counts[i] === undefined) {
      counts[i] = 1 * multiplier;
    } else {
      counts[i] += 1 * multiplier;
    }
  }
});

output = Object.values(counts).reduce((a, b) => a + b, 1) + cards.length - 1;
console.log("answer", output);

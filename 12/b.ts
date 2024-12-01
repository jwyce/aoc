export const x = "";
const input = await Deno.readTextFile("./test.txt");

const history = input.split("\n").filter((x) => x).map((x) => {
  const [records, criteria] = x.split(" ");

  return {
    // records: `${records}?`.repeat(5).slice(0, -1),
    // criteria: `${criteria},`.repeat(5).split(",").filter((x) => x).map(Number),
    records,
    criteria: criteria.split(",").map(Number),
  };
});

function generateCombos(damaged: string) {
  const combos = [damaged];

  for (
    let idx = 0;
    idx < damaged.length;
    idx++
  ) {
    if (damaged[idx] === "?") {
      const len = combos.length;

      for (let i = 0; i < len; i++) {
        const combo = combos.shift()!;

        const replacedWithDot = combo.substring(0, idx) + "." +
          combo.substring(idx + 1);
        combos.push(replacedWithDot);

        const replacedWithHash = combo.substring(0, idx) + "#" +
          combo.substring(idx + 1);
        combos.push(replacedWithHash);
      }
    }
  }

  return combos;
}

let output = 0;

history.forEach(({ records, criteria }, idx) => {
  console.log({ records, criteria });
  const combinations = generateCombos(records);
  console.log(idx, combinations.length);
  let validArrangements = 0;
  combinations.forEach((combo) => {
    const continuousBroken: number[] = [];
    let count = 0;

    for (let i = 0; i < combo.length; i++) {
      if (combo[i] === "#") {
        count++;
      } else {
        if (count > 0) {
          continuousBroken.push(count);
          count = 0;
        }
      }
    }

    if (count > 0) {
      continuousBroken.push(count);
    }

    // console.log({ combo, continuousBroken, criteria });
    if (JSON.stringify(continuousBroken) === JSON.stringify(criteria)) {
      // console.log({ combo });
      validArrangements++;
    }
  });

  console.log({ validArrangements });
  output += validArrangements;
});

console.log("answer", output);

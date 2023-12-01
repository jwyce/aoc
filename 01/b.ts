export const x = "";
const input = await Deno.readTextFile("./input.txt");

const englishToNumber: Record<string, number> = {
  "one": 1,
  "two": 2,
  "three": 3,
  "four": 4,
  "five": 5,
  "six": 6,
  "seven": 7,
  "eight": 8,
  "nine": 9,
};

let output = 0;

input.split("\n").forEach((line) => {
  // console.log({ line });

  const nums = parseNums(line);
  // console.log({ nums });
  const first = +(nums[0] ?? 0);
  const last = +(nums[nums.length - 1] ?? 0);
  // console.log({ first, last });
  const num = first + "" + last;
  // console.log({ num });
  output += +num;
});

console.log("answer", output);

function parseNums(line: string): string[] {
  let word = "";
  const nums = [];

  for (let i = 0; i < line.length; ++i) {
    if (parseInt(line.charAt(i))) {
      nums.push(line.charAt(i));
      word = "";
    } else {
      word += line.charAt(i);

      // console.log({ word });
      if (englishToNumber[word]) {
        nums.push(englishToNumber[word] + "");
        word = word.charAt(word.length - 1);
      } else if (
        !Object.keys(englishToNumber).some((k) => k.startsWith(word))
      ) {
        word = word.substring(1);
      }
    }
  }

  return nums;
}

export const x = "";
const input = await Deno.readTextFile("./input.txt");

let output = 0;

input.split("\n").forEach((line) => {
  const nums = [];
  for (let i = 0; i < line.length; ++i) {
    if (parseInt(line.charAt(i))) {
      nums.push(line.charAt(i));
    }
  }

  const num = (nums[0] ?? "") + (nums[nums.length - 1] ?? "");
  console.log({ num });
  output += +num;
});

console.log("answer", output);

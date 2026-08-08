import childProcess from "node:child_process";

// Global setup runs in Node.js, not workerd
export default function () {
  const label = "Built Gleam worker";
  console.time(label);
  childProcess.execSync("gleam build --target javascript", {
    cwd: __dirname,
  });
  console.timeEnd(label);
}

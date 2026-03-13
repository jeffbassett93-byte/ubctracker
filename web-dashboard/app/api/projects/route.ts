import { NextRequest, NextResponse } from "next/server";
import { promises as fs } from "fs";
import path from "path";

const DATA_FILE = path.join(process.cwd(), "data", "projects.json");

async function ensureDataDir() {
  const dir = path.dirname(DATA_FILE);
  try {
    await fs.access(dir);
  } catch {
    await fs.mkdir(dir, { recursive: true });
  }
}

async function readProjects() {
  try {
    await ensureDataDir();
    const data = await fs.readFile(DATA_FILE, "utf-8");
    return JSON.parse(data);
  } catch {
    return [];
  }
}

async function writeProjects(projects: unknown) {
  await ensureDataDir();
  await fs.writeFile(DATA_FILE, JSON.stringify(projects, null, 2));
}

// GET - Retrieve all projects
export async function GET() {
  const projects = await readProjects();
  return NextResponse.json(projects);
}

// POST - Upload/sync projects from iOS app
export async function POST(request: NextRequest) {
  try {
    const projects = await request.json();
    await writeProjects(projects);
    return NextResponse.json({ success: true, count: Array.isArray(projects) ? projects.length : 0 });
  } catch {
    return NextResponse.json({ error: "Invalid JSON data" }, { status: 400 });
  }
}

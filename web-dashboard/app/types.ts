// Types matching the iOS app's data models

export type RepairType = "concrete" | "fin" | "plate";

export type LocationStatus = "Not Complete" | "Holes Drilled" | "Rebar" | "Rods Installed";

export type StageStatus = "pending" | "in-progress" | "completed" | "delayed";

export interface RodLocation {
  id: string;
  bay: number;
  window: string;
  locationNumber: number;
  status: LocationStatus;
  dateCompleted?: string;
  technician?: string;
  notes?: string;
}

export interface Wall {
  id: string;
  name: string;
  bays: number;
  windows: string[];
  locationsPerWindow: number;
  locations: RodLocation[];
}

export interface Stage {
  id: string;
  name: string;
  description: string;
  duration: number;
  status: StageStatus;
  order: number;
}

export interface Project {
  id: string;
  name: string;
  location: string;
  startDate: string;
  endDate: string;
  walls: Record<string, Wall>;
  stages: Stage[];
  createdAt: string;
  updatedAt: string;
  repairType: RepairType;
}

// Computed helpers
export function getWallStats(wall: Wall) {
  const total = wall.locations.length;
  const rodsInstalled = wall.locations.filter(l => l.status === "Rods Installed").length;
  const holesDrilled = wall.locations.filter(l => l.status === "Holes Drilled").length;
  const rebar = wall.locations.filter(l => l.status === "Rebar").length;
  const notComplete = wall.locations.filter(l => l.status === "Not Complete").length;
  const progressPercentage = total > 0 ? Math.round((rodsInstalled / total) * 100) : 0;

  return { total, rodsInstalled, holesDrilled, rebar, notComplete, progressPercentage };
}

export function getProjectStats(project: Project) {
  const walls = Object.values(project.walls);
  const totalLocations = walls.reduce((sum, w) => sum + w.locations.length, 0);
  const completedLocations = walls.reduce(
    (sum, w) => sum + w.locations.filter(l => l.status === "Rods Installed").length,
    0
  );
  const progressPercentage = totalLocations > 0 ? Math.round((completedLocations / totalLocations) * 100) : 0;

  return { totalLocations, completedLocations, progressPercentage, wallCount: walls.length };
}

export function getRepairTypeLabel(type: RepairType): string {
  switch (type) {
    case "concrete": return "Concrete Repair";
    case "fin": return "Fin Repair";
    case "plate": return "Plate Installation";
  }
}

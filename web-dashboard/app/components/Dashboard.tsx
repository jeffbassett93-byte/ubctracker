"use client";

import { useState, useEffect } from "react";
import { Project, RepairType, getProjectStats, getRepairTypeLabel } from "../types";
import ProjectCard from "./ProjectCard";
import WallCard from "./WallCard";
import StageTimeline from "./StageTimeline";
import { Building2, Grid3x3, Layers, ArrowLeft, RefreshCw } from "lucide-react";

const repairTypes: { type: RepairType; icon: React.ReactNode }[] = [
  { type: "concrete", icon: <Building2 className="w-4 h-4" /> },
  { type: "fin", icon: <Grid3x3 className="w-4 h-4" /> },
  { type: "plate", icon: <Layers className="w-4 h-4" /> },
];

export default function Dashboard() {
  const [projects, setProjects] = useState<Project[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedType, setSelectedType] = useState<RepairType | "all">("all");
  const [selectedProject, setSelectedProject] = useState<Project | null>(null);
  const [lastUpdated, setLastUpdated] = useState<Date | null>(null);

  const fetchProjects = async () => {
    setLoading(true);
    try {
      const res = await fetch("/api/projects");
      const data = await res.json();
      setProjects(data);
      setLastUpdated(new Date());
    } catch (err) {
      console.error("Failed to fetch projects:", err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchProjects();
  }, []);

  const filteredProjects = selectedType === "all"
    ? projects
    : projects.filter((p) => p.repairType === selectedType);

  // Summary stats
  const totalProjects = projects.length;
  const totalLocations = projects.reduce((sum, p) => sum + getProjectStats(p).totalLocations, 0);
  const totalCompleted = projects.reduce((sum, p) => sum + getProjectStats(p).completedLocations, 0);
  const overallProgress = totalLocations > 0 ? Math.round((totalCompleted / totalLocations) * 100) : 0;

  if (selectedProject) {
    const stats = getProjectStats(selectedProject);
    const sortedWalls = Object.entries(selectedProject.walls).sort(([a], [b]) => a.localeCompare(b));

    return (
      <div className="min-h-screen bg-gray-50">
        <header className="bg-white border-b border-gray-200 sticky top-0 z-10">
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-4">
            <div className="flex items-center gap-4">
              <button
                onClick={() => setSelectedProject(null)}
                className="p-2 hover:bg-gray-100 rounded-xl transition-colors"
              >
                <ArrowLeft className="w-5 h-5 text-gray-600" />
              </button>
              <div className="flex-1">
                <h1 className="text-xl font-bold text-gray-900">{selectedProject.name}</h1>
                <p className="text-sm text-gray-500">{selectedProject.location} · {getRepairTypeLabel(selectedProject.repairType)}</p>
              </div>
              <div className="text-right">
                <div className={`text-3xl font-bold ${stats.progressPercentage >= 75 ? "text-green-600" : stats.progressPercentage >= 40 ? "text-blue-600" : "text-gray-600"}`}>
                  {stats.progressPercentage}%
                </div>
                <p className="text-xs text-gray-500">{stats.completedLocations}/{stats.totalLocations} complete</p>
              </div>
            </div>
          </div>
        </header>

        <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          {/* Overall Progress */}
          <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 mb-8">
            <div className="flex items-center justify-between mb-3">
              <h3 className="font-semibold text-gray-900">Overall Progress</h3>
              <span className="text-sm text-gray-500">{stats.wallCount} walls · {stats.totalLocations} locations</span>
            </div>
            <div className="w-full bg-gray-100 rounded-full h-4">
              <div
                className={`h-4 rounded-full transition-all duration-700 ${stats.progressPercentage >= 75 ? "bg-green-500" : stats.progressPercentage >= 40 ? "bg-blue-500" : "bg-gray-400"}`}
                style={{ width: `${stats.progressPercentage}%` }}
              />
            </div>
            {/* Status summary row */}
            <div className="flex gap-6 mt-4">
              {(() => {
                const allLocs = Object.values(selectedProject.walls).flatMap(w => w.locations);
                const installed = allLocs.filter(l => l.status === "Rods Installed").length;
                const drilled = allLocs.filter(l => l.status === "Holes Drilled").length;
                const rebar = allLocs.filter(l => l.status === "Rebar").length;
                const notComplete = allLocs.filter(l => l.status === "Not Complete").length;
                return (
                  <>
                    <div className="flex items-center gap-2 text-sm">
                      <div className="w-3 h-3 rounded-sm bg-green-500" />
                      <span className="text-gray-600">Rods Installed: <strong>{installed}</strong></span>
                    </div>
                    <div className="flex items-center gap-2 text-sm">
                      <div className="w-3 h-3 rounded-sm bg-blue-500" />
                      <span className="text-gray-600">Holes Drilled: <strong>{drilled}</strong></span>
                    </div>
                    <div className="flex items-center gap-2 text-sm">
                      <div className="w-3 h-3 rounded-sm bg-orange-500" />
                      <span className="text-gray-600">Rebar: <strong>{rebar}</strong></span>
                    </div>
                    <div className="flex items-center gap-2 text-sm">
                      <div className="w-3 h-3 rounded-sm bg-gray-300" />
                      <span className="text-gray-600">Not Complete: <strong>{notComplete}</strong></span>
                    </div>
                  </>
                );
              })()}
            </div>
          </div>

          {/* Walls Grid */}
          <h3 className="font-semibold text-gray-900 mb-4">Walls</h3>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-8">
            {sortedWalls.map(([name, wall]) => (
              <WallCard key={name} wall={wall} />
            ))}
          </div>

          {/* Stages Timeline */}
          {selectedProject.stages.length > 0 && (
            <StageTimeline stages={selectedProject.stages} />
          )}
        </main>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Header */}
      <header className="bg-white border-b border-gray-200 sticky top-0 z-10">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
          <div className="flex items-center justify-between">
            <div>
              <h1 className="text-2xl font-bold text-gray-900">Repair Tracker Dashboard</h1>
              <p className="text-sm text-gray-500 mt-1">UBC Facade Rod Installation Progress</p>
            </div>
            <button
              onClick={fetchProjects}
              className="flex items-center gap-2 px-4 py-2 text-sm font-medium text-gray-600 bg-gray-100 hover:bg-gray-200 rounded-xl transition-colors"
            >
              <RefreshCw className={`w-4 h-4 ${loading ? "animate-spin" : ""}`} />
              Refresh
            </button>
          </div>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Summary Cards */}
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
          <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-5">
            <p className="text-sm text-gray-500 mb-1">Total Projects</p>
            <p className="text-3xl font-bold text-gray-900">{totalProjects}</p>
          </div>
          <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-5">
            <p className="text-sm text-gray-500 mb-1">Total Locations</p>
            <p className="text-3xl font-bold text-gray-900">{totalLocations.toLocaleString()}</p>
          </div>
          <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-5">
            <p className="text-sm text-gray-500 mb-1">Completed</p>
            <p className="text-3xl font-bold text-green-600">{totalCompleted.toLocaleString()}</p>
          </div>
          <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-5">
            <p className="text-sm text-gray-500 mb-1">Overall Progress</p>
            <p className={`text-3xl font-bold ${overallProgress >= 75 ? "text-green-600" : overallProgress >= 40 ? "text-blue-600" : "text-gray-600"}`}>
              {overallProgress}%
            </p>
          </div>
        </div>

        {/* Filter Tabs */}
        <div className="flex items-center gap-2 mb-6">
          <button
            onClick={() => setSelectedType("all")}
            className={`px-4 py-2 rounded-xl text-sm font-medium transition-colors ${selectedType === "all" ? "bg-gray-900 text-white" : "bg-white text-gray-600 hover:bg-gray-100 border border-gray-200"}`}
          >
            All ({projects.length})
          </button>
          {repairTypes.map(({ type, icon }) => {
            const count = projects.filter(p => p.repairType === type).length;
            return (
              <button
                key={type}
                onClick={() => setSelectedType(type)}
                className={`flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-medium transition-colors ${selectedType === type ? "bg-gray-900 text-white" : "bg-white text-gray-600 hover:bg-gray-100 border border-gray-200"}`}
              >
                {icon}
                {getRepairTypeLabel(type)} ({count})
              </button>
            );
          })}
        </div>

        {/* Projects Grid */}
        {loading ? (
          <div className="flex items-center justify-center py-20">
            <RefreshCw className="w-8 h-8 text-gray-400 animate-spin" />
          </div>
        ) : filteredProjects.length === 0 ? (
          <div className="text-center py-20">
            <Building2 className="w-16 h-16 text-gray-300 mx-auto mb-4" />
            <h3 className="text-lg font-semibold text-gray-500 mb-2">No Projects Yet</h3>
            <p className="text-sm text-gray-400">
              Upload project data from the iOS app using the API endpoint.
            </p>
            <div className="mt-6 bg-white rounded-xl border border-gray-200 p-4 max-w-lg mx-auto text-left">
              <p className="text-xs font-mono text-gray-500 mb-2">POST /api/projects</p>
              <p className="text-xs text-gray-400">Send your project JSON data to populate the dashboard.</p>
            </div>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {filteredProjects.map((project) => (
              <ProjectCard
                key={project.id}
                project={project}
                onClick={() => setSelectedProject(project)}
              />
            ))}
          </div>
        )}

        {/* Footer */}
        {lastUpdated && (
          <p className="text-center text-xs text-gray-400 mt-12">
            Last updated: {lastUpdated.toLocaleString()}
          </p>
        )}
      </main>
    </div>
  );
}

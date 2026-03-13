"use client";

import { Project, getProjectStats, getRepairTypeLabel } from "../types";
import { Building2, Grid3x3, Layers, MapPin, Calendar } from "lucide-react";

function repairTypeIcon(type: string) {
  switch (type) {
    case "concrete": return <Building2 className="w-5 h-5" />;
    case "fin": return <Grid3x3 className="w-5 h-5" />;
    case "plate": return <Layers className="w-5 h-5" />;
    default: return <Building2 className="w-5 h-5" />;
  }
}

export default function ProjectCard({ project, onClick }: { project: Project; onClick: () => void }) {
  const stats = getProjectStats(project);

  return (
    <button
      onClick={onClick}
      className="w-full text-left bg-white rounded-2xl shadow-sm border border-gray-100 p-6 hover:shadow-md hover:border-gray-200 transition-all duration-200 cursor-pointer"
    >
      <div className="flex items-start justify-between mb-4">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-blue-50 text-blue-600 rounded-xl">
            {repairTypeIcon(project.repairType)}
          </div>
          <div>
            <h3 className="font-semibold text-gray-900 text-lg">{project.name}</h3>
            <div className="flex items-center gap-1 text-gray-500 text-sm mt-0.5">
              <MapPin className="w-3.5 h-3.5" />
              <span>{project.location}</span>
            </div>
          </div>
        </div>
        <span className="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-medium bg-gray-100 text-gray-600">
          {getRepairTypeLabel(project.repairType)}
        </span>
      </div>

      {/* Progress Bar */}
      <div className="mb-4">
        <div className="flex justify-between items-end mb-2">
          <span className="text-sm text-gray-500">
            {stats.completedLocations} of {stats.totalLocations} completed
          </span>
          <span className={`text-2xl font-bold ${stats.progressPercentage >= 75 ? "text-green-600" : stats.progressPercentage >= 40 ? "text-blue-600" : "text-gray-600"}`}>
            {stats.progressPercentage}%
          </span>
        </div>
        <div className="w-full bg-gray-100 rounded-full h-2.5">
          <div
            className={`h-2.5 rounded-full transition-all duration-500 ${stats.progressPercentage >= 75 ? "bg-green-500" : stats.progressPercentage >= 40 ? "bg-blue-500" : "bg-gray-400"}`}
            style={{ width: `${stats.progressPercentage}%` }}
          />
        </div>
      </div>

      {/* Stats Row */}
      <div className="flex items-center gap-4 text-sm text-gray-500">
        <div className="flex items-center gap-1">
          <div className="w-2 h-2 rounded-full bg-blue-400" />
          <span>{stats.wallCount} walls</span>
        </div>
        <div className="flex items-center gap-1">
          <div className="w-2 h-2 rounded-full bg-gray-400" />
          <span>{stats.totalLocations} locations</span>
        </div>
        {project.updatedAt && (
          <div className="flex items-center gap-1 ml-auto">
            <Calendar className="w-3.5 h-3.5" />
            <span>{new Date(project.updatedAt).toLocaleDateString()}</span>
          </div>
        )}
      </div>
    </button>
  );
}

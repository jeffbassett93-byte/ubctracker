"use client";

import { Wall, getWallStats } from "../types";

const statusColors: Record<string, string> = {
  "Rods Installed": "bg-green-500",
  "Holes Drilled": "bg-blue-500",
  "Rebar": "bg-orange-500",
  "Not Complete": "bg-gray-300",
};

export default function WallCard({ wall }: { wall: Wall }) {
  const stats = getWallStats(wall);

  return (
    <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-5">
      <div className="flex items-center justify-between mb-4">
        <h4 className="font-semibold text-gray-900">{wall.name}</h4>
        <span className={`text-lg font-bold ${stats.progressPercentage >= 75 ? "text-green-600" : stats.progressPercentage >= 40 ? "text-blue-600" : "text-gray-500"}`}>
          {stats.progressPercentage}%
        </span>
      </div>

      {/* Circular Progress */}
      <div className="flex justify-center mb-4">
        <div className="relative w-24 h-24">
          <svg className="w-24 h-24 -rotate-90" viewBox="0 0 100 100">
            <circle cx="50" cy="50" r="42" fill="none" stroke="#e5e7eb" strokeWidth="8" />
            <circle
              cx="50" cy="50" r="42" fill="none"
              stroke={stats.progressPercentage >= 75 ? "#22c55e" : stats.progressPercentage >= 40 ? "#3b82f6" : "#9ca3af"}
              strokeWidth="8"
              strokeLinecap="round"
              strokeDasharray={`${stats.progressPercentage * 2.64} ${264 - stats.progressPercentage * 2.64}`}
            />
          </svg>
          <div className="absolute inset-0 flex items-center justify-center">
            <span className="text-sm font-bold text-gray-700">{stats.rodsInstalled}/{stats.total}</span>
          </div>
        </div>
      </div>

      {/* Status Breakdown */}
      <div className="grid grid-cols-2 gap-2 text-sm">
        <div className="flex items-center gap-2">
          <div className="w-3 h-3 rounded-sm bg-green-500" />
          <span className="text-gray-600">Installed: <strong>{stats.rodsInstalled}</strong></span>
        </div>
        <div className="flex items-center gap-2">
          <div className="w-3 h-3 rounded-sm bg-blue-500" />
          <span className="text-gray-600">Drilled: <strong>{stats.holesDrilled}</strong></span>
        </div>
        <div className="flex items-center gap-2">
          <div className="w-3 h-3 rounded-sm bg-orange-500" />
          <span className="text-gray-600">Rebar: <strong>{stats.rebar}</strong></span>
        </div>
        <div className="flex items-center gap-2">
          <div className="w-3 h-3 rounded-sm bg-gray-300" />
          <span className="text-gray-600">Pending: <strong>{stats.notComplete}</strong></span>
        </div>
      </div>

      {/* Location Grid */}
      <div className="mt-4 pt-4 border-t border-gray-100">
        <p className="text-xs text-gray-400 mb-2">{wall.bays} bays × {wall.windows.length} windows</p>
        <div className="flex flex-wrap gap-0.5">
          {wall.locations.map((loc) => (
            <div
              key={loc.id}
              className={`w-2.5 h-2.5 rounded-[2px] ${statusColors[loc.status]}`}
              title={`Bay ${loc.bay}, ${loc.window}-${loc.locationNumber}: ${loc.status}`}
            />
          ))}
        </div>
      </div>
    </div>
  );
}

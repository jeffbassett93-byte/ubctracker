"use client";

import { Stage } from "../types";
import { CheckCircle2, Clock, AlertTriangle, Circle } from "lucide-react";

function stageIcon(status: string) {
  switch (status) {
    case "completed": return <CheckCircle2 className="w-5 h-5 text-green-500" />;
    case "in-progress": return <Clock className="w-5 h-5 text-blue-500" />;
    case "delayed": return <AlertTriangle className="w-5 h-5 text-amber-500" />;
    default: return <Circle className="w-5 h-5 text-gray-300" />;
  }
}

function statusBadge(status: string) {
  const styles: Record<string, string> = {
    completed: "bg-green-50 text-green-700",
    "in-progress": "bg-blue-50 text-blue-700",
    delayed: "bg-amber-50 text-amber-700",
    pending: "bg-gray-50 text-gray-500",
  };
  const labels: Record<string, string> = {
    completed: "Completed",
    "in-progress": "In Progress",
    delayed: "Delayed",
    pending: "Pending",
  };
  return (
    <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${styles[status] || styles.pending}`}>
      {labels[status] || "Pending"}
    </span>
  );
}

export default function StageTimeline({ stages }: { stages: Stage[] }) {
  const sorted = [...stages].sort((a, b) => a.order - b.order);

  if (sorted.length === 0) return null;

  return (
    <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
      <h3 className="font-semibold text-gray-900 mb-4">Project Stages</h3>
      <div className="space-y-0">
        {sorted.map((stage, i) => (
          <div key={stage.id} className="flex gap-4">
            {/* Timeline line + icon */}
            <div className="flex flex-col items-center">
              {stageIcon(stage.status)}
              {i < sorted.length - 1 && (
                <div className={`w-0.5 flex-1 my-1 ${stage.status === "completed" ? "bg-green-200" : "bg-gray-200"}`} />
              )}
            </div>
            {/* Content */}
            <div className="pb-6 flex-1">
              <div className="flex items-center gap-2 mb-1">
                <span className="font-medium text-gray-800 text-sm">{stage.name}</span>
                {statusBadge(stage.status)}
              </div>
              <p className="text-xs text-gray-500">{stage.description}</p>
              <p className="text-xs text-gray-400 mt-1">{stage.duration} day{stage.duration !== 1 ? "s" : ""}</p>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

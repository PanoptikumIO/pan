defmodule PanWeb.PageFrontendController do
  use PanWeb, :controller
  alias PanWeb.Podcast

  def home(conn, _params) do
    popular_podcasts =
      from(p in Podcast,
        select: [p.subscriptions_count, p.id, p.title],
        order_by: [fragment("? DESC NULLS LAST", p.subscriptions_count)],
        limit: 15
      )
      |> Repo.all()

    liked_podcasts =
      from(p in Podcast,
        select: [p.likes_count, p.id, p.title],
        order_by: [fragment("? DESC NULLS LAST", p.likes_count)],
        limit: 10
      )
      |> Repo.all()

    render(conn, "home.sface",
      popular_podcasts: popular_podcasts,
      liked_podcasts: liked_podcasts
    )
  end

  def pro_features(conn, _params) do
    render(conn, "pro_features.html")
  end

  def sandbox(conn, _params) do
    render(conn, "sandbox.html")
  end

  def color_translator(conn, _params) do
    bootflat_with_nearest = bootflat_colors()
    |> Enum.map(fn {name, tint} -> {name, Tint.RGB.to_hex(tint), nearest_tailwind_name(tint)} end)

    render(conn, "color_translator.html",
      tailwind_colors: tailwind_colors(),
      bootflat_with_nearest: bootflat_with_nearest
    )
  end

  defp tailwind_colors() do
    %{
      "blueGray-50": "#F8FAFC",
      "blueGray-100": "#F1F5F9",
      "blueGray-200": "#E2E8F0",
      "blueGray-300": "#CBD5E1",
      "blueGray-400": "#94A3B8",
      "blueGray-500": "#64748B",
      "blueGray-600": "#475569",
      "blueGray-700": "#334155",
      "blueGray-800": "#1E293B",
      "blueGray-900": "#0F172A",
      "coolGray-50": "#F9FAFB",
      "coolGray-100": "#F3F4F6",
      "coolGray-200": "#E5E7EB",
      "coolGray-300": "#D1D5DB",
      "coolGray-400": "#9CA3AF",
      "coolGray-500": "#6B7280",
      "coolGray-600": "#4B5563",
      "coolGray-700": "#374151",
      "coolGray-800": "#1F2937",
      "coolGray-900": "#111827",
      "gray-50": "#FAFAFA",
      "gray-100": "#F4F4F5",
      "gray-200": "#E4E4E7",
      "gray-300": "#D4D4D8",
      "gray-400": "#A1A1AA",
      "gray-500": "#71717A",
      "gray-600": "#52525B",
      "gray-700": "#3F3F46",
      "gray-800": "#27272A",
      "gray-900": "#18181B",
      "trueGray-50": "#FAFAFA",
      "trueGray-100": "#F5F5F5",
      "trueGray-200": "#E5E5E5",
      "trueGray-300": "#D4D4D4",
      "trueGray-400": "#A3A3A3",
      "trueGray-500": "#737373",
      "trueGray-600": "#525252",
      "trueGray-700": "#404040",
      "trueGray-800": "#262626",
      "trueGray-900": "#171717",
      "warmGray-50": "#FAFAF9",
      "warmGray-100": "#F5F5F4",
      "warmGray-200": "#E7E5E4",
      "warmGray-300": "#D6D3D1",
      "warmGray-400": "#A8A29E",
      "warmGray-500": "#78716C",
      "warmGray-600": "#57534E",
      "warmGray-700": "#44403C",
      "warmGray-800": "#292524",
      "warmGray-900": "#1C1917",
      "red-50": "#FEF2F2",
      "red-100": "#FEE2E2",
      "red-200": "#FECACA",
      "red-300": "#FCA5A5",
      "red-400": "#F87171",
      "red-500": "#EF4444",
      "red-600": "#DC2626",
      "red-700": "#B91C1C",
      "red-800": "#991B1B",
      "red-900": "#7F1D1D",
      "orange-50": "#FFF7ED",
      "orange-100": "#FFEDD5",
      "orange-200": "#FED7AA",
      "orange-300": "#FDBA74",
      "orange-400": "#FB923C",
      "orange-500": "#F97316",
      "orange-600": "#EA580C",
      "orange-700": "#C2410C",
      "orange-800": "#9A3412",
      "orange-900": "#7C2D12",
      "amber-50": "#FFFBEB",
      "amber-100": "#FEF3C7",
      "amber-200": "#FDE68A",
      "amber-300": "#FCD34D",
      "amber-400": "#FBBF24",
      "amber-500": "#F59E0B",
      "amber-600": "#D97706",
      "amber-700": "#B45309",
      "amber-800": "#92400E",
      "amber-900": "#78350F",
      "yellow-50": "#FEFCE8",
      "yellow-100": "#FEF9C3",
      "yellow-200": "#FEF08A",
      "yellow-300": "#FDE047",
      "yellow-400": "#FACC15",
      "yellow-500": "#EAB308",
      "yellow-600": "#CA8A04",
      "yellow-700": "#A16207",
      "yellow-800": "#854D0E",
      "yellow-900": "#713F12",
      "lime-50": "#F7FEE7",
      "lime-100": "#ECFCCB",
      "lime-200": "#D9F99D",
      "lime-300": "#BEF264",
      "lime-400": "#A3E635",
      "lime-500": "#84CC16",
      "lime-600": "#65A30D",
      "lime-700": "#4D7C0F",
      "lime-800": "#3F6212",
      "lime-900": "#365314",
      "green-50": "#F0FDF4",
      "green-100": "#DCFCE7",
      "green-200": "#BBF7D0",
      "green-300": "#86EFAC",
      "green-400": "#4ADE80",
      "green-500": "#22C55E",
      "green-600": "#16A34A",
      "green-700": "#15803D",
      "green-800": "#166534",
      "green-900": "#14532D",
      "emerald-50": "#ECFDF5",
      "emerald-100": "#D1FAE5",
      "emerald-200": "#A7F3D0",
      "emerald-300": "#6EE7B7",
      "emerald-400": "#34D399",
      "emerald-500": "#10B981",
      "emerald-600": "#059669",
      "emerald-700": "#047857",
      "emerald-800": "#065F46",
      "emerald-900": "#064E3B",
      "teal-50": "#F0FDFA",
      "teal-100": "#CCFBF1",
      "teal-200": "#99F6E4",
      "teal-300": "#5EEAD4",
      "teal-400": "#2DD4BF",
      "teal-500": "#14B8A6",
      "teal-600": "#0D9488",
      "teal-700": "#0F766E",
      "teal-800": "#115E59",
      "teal-900": "#134E4A",
      "cyan-50": "#ECFEFF",
      "cyan-100": "#CFFAFE",
      "cyan-200": "#A5F3FC",
      "cyan-300": "#67E8F9",
      "cyan-400": "#22D3EE",
      "cyan-500": "#06B6D4",
      "cyan-600": "#0891B2",
      "cyan-700": "#0E7490",
      "cyan-800": "#155E75",
      "cyan-900": "#164E63",
      "lightBlue-50": "#F0F9FF",
      "lightBlue-100": "#E0F2FE",
      "lightBlue-200": "#BAE6FD",
      "lightBlue-300": "#7DD3FC",
      "lightBlue-400": "#38BDF8",
      "lightBlue-500": "#0EA5E9",
      "lightBlue-600": "#0284C7",
      "lightBlue-700": "#0369A1",
      "lightBlue-800": "#075985",
      "lightBlue-900": "#0C4A6E",
      "blue-50": "#EFF6FF",
      "blue-100": "#DBEAFE",
      "blue-200": "#BFDBFE",
      "blue-300": "#93C5FD",
      "blue-400": "#60A5FA",
      "blue-500": "#3B82F6",
      "blue-600": "#2563EB",
      "blue-700": "#1D4ED8",
      "blue-800": "#1E40AF",
      "blue-900": "#1E3A8A",
      "indigo-50": "#EEF2FF",
      "indigo-100": "#E0E7FF",
      "indigo-200": "#C7D2FE",
      "indigo-300": "#A5B4FC",
      "indigo-400": "#818CF8",
      "indigo-500": "#6366F1",
      "indigo-600": "#4F46E5",
      "indigo-700": "#4338CA",
      "indigo-800": "#3730A3",
      "indigo-900": "#312E81",
      "violet-50": "#F5F3FF",
      "violet-100": "#EDE9FE",
      "violet-200": "#DDD6FE",
      "violet-300": "#C4B5FD",
      "violet-400": "#A78BFA",
      "violet-500": "#8B5CF6",
      "violet-600": "#7C3AED",
      "violet-700": "#6D28D9",
      "violet-800": "#5B21B6",
      "violet-900": "#4C1D95",
      "purple-50": "#FAF5FF",
      "purple-100": "#F3E8FF",
      "purple-200": "#E9D5FF",
      "purple-300": "#D8B4FE",
      "purple-400": "#C084FC",
      "purple-500": "#A855F7",
      "purple-600": "#9333EA",
      "purple-700": "#7E22CE",
      "purple-800": "#6B21A8",
      "purple-900": "#581C87",
      "fuchsia-50": "#FDF4FF",
      "fuchsia-100": "#FAE8FF",
      "fuchsia-200": "#F5D0FE",
      "fuchsia-300": "#F0ABFC",
      "fuchsia-400": "#E879F9",
      "fuchsia-500": "#D946EF",
      "fuchsia-600": "#C026D3",
      "fuchsia-700": "#A21CAF",
      "fuchsia-800": "#86198F",
      "fuchsia-900": "#701A75",
      "pink-50": "#FDF2F8",
      "pink-100": "#FCE7F3",
      "pink-200": "#FBCFE8",
      "pink-300": "#F9A8D4",
      "pink-400": "#F472B6",
      "pink-500": "#EC4899",
      "pink-600": "#DB2777",
      "pink-700": "#BE185D",
      "pink-800": "#9D174D",
      "pink-900": "#831843",
      "rose-50": "#FFF1F2",
      "rose-100": "#FFE4E6",
      "rose-200": "#FECDD3",
      "rose-300": "#FDA4AF",
      "rose-400": "#FB7185",
      "rose-500": "#F43F5E",
      "rose-600": "#E11D48",
      "rose-700": "#BE123C",
      "rose-800": "#9F1239",
      "rose-900": "#881337",
    }
    |> get_tints()
  end

  defp bootflat_colors do
    %{
      "blue-jeans": "#4A89DC",
      aqua: "#3BAFDA",
      mint: "#37BC9B",
      grass: "#8CC152",
      sunflower: "#F6BB42",
      bittersweet: "#E9573F",
      grapefruit: "#DA4453",
      lavender: "#967ADC",
      "pink-rose": "#D770AD",
      "very-light-gray": "#F5F7FA",
      "light-gray": "#E6E9ED",
      "light-medium-gray": "#CCD1D9",
      "medium-gray": "#AAB2BD",
      "medium-dark-gray": "#656D78",
      "dark-gray": "#434A54",
      "nav-background": "#434A54",
      "success-light": "#B9DF90",
      success: "#8CC152",
      "success-dark": "#3C763D",
      "warning-light": "#FFDD87",
      warning: "#F6BB42",
      "warning-dark": "#8A6D3B",
      "danger-light": "#F2838F",
      danger: "#DA4453",
      "danger-dark": "#A94442",
      "info-light": "#7CD1EF",
      info: "#3BAFDA",
      "info-dark": "#31708F"
    }
    |> get_tints()
  end

  def get_tints(colors) do
    for {name, hex} <- colors, into: %{}, do: {name, Tint.RGB.from_hex!(hex)}
  end

  defp find_tailwind_name(tint) do
    tailwind_colors()
    |> Enum.find(fn {_, val} -> val == tint end)
    |> elem(0)
  end

  defp nearest_tailwind_name(tint) do
    tint
    |> Tint.Lab.nearest_color(tailwind_colors() |> Map.values())
    |> find_tailwind_name()
  end
end

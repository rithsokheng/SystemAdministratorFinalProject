#!/bin/bash
# run as root on VM 1 (Web Server)

# Update and install required packages
apt update && apt upgrade -y
apt install -y apache2 openssh-server

# Enable and start services
systemctl enable --now ssh
systemctl enable --now apache2

# Create a custom website for the 3-member team
cat <<'EOF' > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chesster</title>
    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@600;700;800;900&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <!-- FontAwesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        body {
            font-family: 'Inter', sans-serif;
            background: radial-gradient(circle at center, #1e293b 0%, #0f172a 100%);
            min-height: 100vh;
            color: #f8fafc;
            user-select: none;
            -webkit-user-select: none;
        }

        .font-cinzel {
            font-family: 'Cinzel', serif;
        }

        /* Chessboard Themes */
        .theme-wood {
            --sq-light: #e0c398;
            --sq-dark: #8b5a2b;
            --sq-light-hl: #f5dfb8;
            --sq-dark-hl: #a66f38;
            --board-border: #4a2c11;
        }

        .theme-slate {
            --sq-light: #e2e8f0;
            --sq-dark: #475569;
            --sq-light-hl: #f1f5f9;
            --sq-dark-hl: #64748b;
            --board-border: #1e293b;
        }

        .theme-emerald {
            --sq-light: #e2e8f0;
            --sq-dark: #15803d;
            --sq-light-hl: #f1f5f9;
            --sq-dark-hl: #16a34a;
            --board-border: #064e3b;
        }

        .theme-cyber {
            --sq-light: #334155;
            --sq-dark: #0f172a;
            --sq-light-hl: #475569;
            --sq-dark-hl: #1e293b;
            --board-border: #3b82f6;
        }

        .chess-square {
            transition: background-color 0.15s ease, transform 0.1s ease;
        }

        .square-light { background-color: var(--sq-light); color: var(--sq-dark); }
        .square-dark { background-color: var(--sq-dark); color: var(--sq-light); }
        
        /* Selected & Highlighted Squares */
        .square-selected {
            background-color: #f59e0b !important;
        }

        .square-last-move {
            background-color: rgba(250, 204, 21, 0.45) !important;
        }

        .square-in-check {
            background-color: #ef4444 !important;
            animation: pulse-red 1.2s infinite;
        }

        @keyframes pulse-red {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.65; }
        }

        /* Move Indicator Overlay */
        .move-indicator {
            position: absolute;
            width: 32%;
            height: 32%;
            border-radius: 50%;
            background-color: rgba(16, 185, 129, 0.7);
            pointer-events: none;
            box-shadow: 0 0 8px rgba(16, 185, 129, 0.8);
        }

        .capture-indicator {
            position: absolute;
            width: 90%;
            height: 90%;
            border-radius: 50%;
            border: 4px solid rgba(239, 68, 68, 0.75);
            pointer-events: none;
            box-shadow: 0 0 10px rgba(239, 68, 68, 0.6);
        }

        /* Piece Dragging & Smooth Visuals */
        .piece-img {
            cursor: grab;
            filter: drop-shadow(0px 4px 5px rgba(0, 0, 0, 0.45));
            transition: transform 0.1s ease;
        }

        .piece-img:active {
            cursor: grabbing;
            transform: scale(1.12);
        }

        .piece-dragging {
            opacity: 0.4;
        }

        /* Custom Scrollbar for Move History */
        .custom-scrollbar::-webkit-scrollbar {
            width: 6px;
        }
        .custom-scrollbar::-webkit-scrollbar-track {
            background: rgba(15, 23, 42, 0.6);
            border-radius: 4px;
        }
        .custom-scrollbar::-webkit-scrollbar-thumb {
            background: #334155;
            border-radius: 4px;
        }
        .custom-scrollbar::-webkit-scrollbar-thumb:hover {
            background: #475569;
        }
    </style>
</head>
<body class="theme-wood flex flex-col items-center justify-between p-2 md:p-6 min-h-screen">

    <!-- HEADER BRANDING BANNER -->
    <header class="w-full max-w-6xl mb-4 text-center">
        <div class="bg-gradient-to-r from-slate-900 via-slate-800 to-slate-900 border border-amber-500/30 rounded-2xl p-4 shadow-2xl relative overflow-hidden backdrop-blur-md">
            <div class="absolute inset-0 bg-amber-500/5 pointer-events-none"></div>
            <div class="relative z-10 flex flex-col sm:flex-row items-center justify-between gap-3 px-4">
                <div class="flex items-center space-x-3">
                    <div class="bg-gradient-to-tr from-amber-600 to-yellow-400 p-3 rounded-xl shadow-lg text-slate-950 font-black">
                        <i class="fa-solid fa-chess-king text-2xl sm:text-3xl"></i>
                    </div>
                    <div class="text-left">
                        <h1 class="font-cinzel text-2xl sm:text-3xl font-extrabold tracking-wide bg-gradient-to-r from-amber-200 via-yellow-400 to-amber-500 bg-clip-text text-transparent drop-shadow-sm">
                            Chesster
                        </h1>
                    </div>
                </div>

                <!-- Top Control Buttons -->
                <div class="flex items-center gap-2 flex-wrap justify-center">
                    <button id="btn-new-game" class="px-3 py-2 bg-gradient-to-r from-amber-600 to-amber-700 hover:from-amber-500 hover:to-amber-600 text-slate-950 font-bold text-xs sm:text-sm rounded-lg shadow-md transition-all transform active:scale-95 flex items-center gap-2">
                        <i class="fa-solid fa-rotate-right"></i> New Game
                    </button>
                    <button id="btn-undo" class="px-3 py-2 bg-slate-800 hover:bg-slate-700 text-slate-200 border border-slate-700 font-semibold text-xs sm:text-sm rounded-lg shadow transition-all active:scale-95 flex items-center gap-2">
                        <i class="fa-solid fa-rotate-left"></i> Undo
                    </button>
                    <button id="btn-flip" class="px-3 py-2 bg-slate-800 hover:bg-slate-700 text-slate-200 border border-slate-700 font-semibold text-xs sm:text-sm rounded-lg shadow transition-all active:scale-95 flex items-center gap-2">
                        <i class="fa-solid fa-repeat"></i> Flip Board
                    </button>
                    <button id="btn-sound" class="p-2 bg-slate-800 hover:bg-slate-700 text-amber-400 border border-slate-700 rounded-lg shadow transition-all" title="Toggle Sound">
                        <i id="sound-icon" class="fa-solid fa-volume-high text-sm"></i>
                    </button>
                </div>
            </div>
        </div>
    </header>

    <!-- MAIN APPLICATION WORKSPACE -->
    <main class="w-full max-w-6xl grid grid-cols-1 lg:grid-cols-12 gap-6 items-start">

        <!-- LEFT SIDEBAR: Game Options & Player Info -->
        <div class="lg:col-span-3 flex flex-col gap-4 order-2 lg:order-1">

            <!-- Mode & Difficulty Card -->
            <div class="bg-slate-900/90 border border-slate-800 rounded-2xl p-4 shadow-xl backdrop-blur-md">
                <h2 class="text-xs font-bold uppercase text-slate-400 tracking-wider mb-3 flex items-center gap-2">
                    <i class="fa-solid fa-sliders text-amber-500"></i> Game Mode
                </h2>
                
                <div class="space-y-3">
                    <div>
                        <label class="text-xs text-slate-300 mb-1 block">Opponent</label>
                        <select id="select-mode" class="w-full bg-slate-800 border border-slate-700 text-slate-200 rounded-lg p-2.5 text-xs font-semibold focus:ring-2 focus:ring-amber-500 outline-none">
                            <option value="pvp">2-Player (Pass & Play)</option>
                            <option value="ai-easy">VS Computer (Easy AI)</option>
                            <option value="ai-medium" selected>VS Computer (Medium AI)</option>
                        </select>
                    </div>

                    <div>
                        <label class="text-xs text-slate-300 mb-1 block">Play As</label>
                        <select id="select-player-color" class="w-full bg-slate-800 border border-slate-700 text-slate-200 rounded-lg p-2.5 text-xs font-semibold focus:ring-2 focus:ring-amber-500 outline-none">
                            <option value="w" selected>White Pieces</option>
                            <option value="b">Black Pieces</option>
                        </select>
                    </div>

                    <div>
                        <label class="text-xs text-slate-300 mb-1 block">Board Theme</label>
                        <select id="select-theme" class="w-full bg-slate-800 border border-slate-700 text-slate-200 rounded-lg p-2.5 text-xs font-semibold focus:ring-2 focus:ring-amber-500 outline-none">
                            <option value="theme-wood" selected>Classic Wood</option>
                            <option value="theme-slate">Slate & Marble</option>
                            <option value="theme-emerald">Emerald Garden</option>
                            <option value="theme-cyber">Cyberpunk Dark</option>
                        </select>
                    </div>
                </div>
            </div>

            <!-- Player Status & Timer Card -->
            <div class="bg-slate-900/90 border border-slate-800 rounded-2xl p-4 shadow-xl backdrop-blur-md flex flex-col gap-3">
                <!-- Black Player Card -->
                <div id="card-player-b" class="flex items-center justify-between p-3 rounded-xl bg-slate-800/60 border border-slate-700/50 transition-all">
                    <div class="flex items-center gap-3">
                        <div class="w-9 h-9 rounded-lg bg-slate-950 border border-slate-700 flex items-center justify-center text-white text-lg shadow">
                            <i class="fa-solid fa-user-ninja"></i>
                        </div>
                        <div>
                            <div class="text-xs font-bold text-slate-200 flex items-center gap-2">
                                Black Player <span id="badge-turn-b" class="hidden text-[10px] bg-amber-500/20 text-amber-400 px-2 py-0.5 rounded-full font-bold">TURN</span>
                            </div>
                            <div id="captured-w" class="text-xs text-slate-400 flex flex-wrap gap-1 mt-0.5 h-4 items-center">
                                <!-- Captured white pieces go here -->
                            </div>
                        </div>
                    </div>
                    <div id="timer-b" class="font-mono text-sm font-bold text-slate-300 bg-slate-950 px-2.5 py-1 rounded-md border border-slate-800">
                        10:00
                    </div>
                </div>

                <!-- White Player Card -->
                <div id="card-player-w" class="flex items-center justify-between p-3 rounded-xl bg-slate-800/60 border border-amber-500/40 shadow-sm transition-all">
                    <div class="flex items-center gap-3">
                        <div class="w-9 h-9 rounded-lg bg-slate-100 border border-slate-300 flex items-center justify-center text-slate-900 text-lg shadow">
                            <i class="fa-solid fa-user"></i>
                        </div>
                        <div>
                            <div class="text-xs font-bold text-slate-200 flex items-center gap-2">
                                White Player <span id="badge-turn-w" class="text-[10px] bg-amber-500/20 text-amber-400 px-2 py-0.5 rounded-full font-bold">TURN</span>
                            </div>
                            <div id="captured-b" class="text-xs text-slate-400 flex flex-wrap gap-1 mt-0.5 h-4 items-center">
                                <!-- Captured black pieces go here -->
                            </div>
                        </div>
                    </div>
                    <div id="timer-w" class="font-mono text-sm font-bold text-slate-300 bg-slate-950 px-2.5 py-1 rounded-md border border-slate-800">
                        10:00
                    </div>
                </div>
            </div>

            <!-- Active Status Alert Box -->
            <div id="status-banner" class="bg-amber-500/10 border border-amber-500/30 rounded-xl p-3 text-center transition-all">
                <span id="status-text" class="text-xs font-bold text-amber-300 tracking-wide uppercase">
                    White's turn to move
                </span>
            </div>
        </div>

        <!-- CENTER CHESS BOARD -->
        <div class="lg:col-span-6 flex flex-col items-center order-1 lg:order-2">
            <!-- Board Container Outer Rim -->
            <div class="relative p-3 sm:p-4 rounded-2xl bg-gradient-to-b from-slate-800 to-slate-950 border-4 border-slate-800 shadow-2xl max-w-full">
                <!-- Outer Border Framing -->
                <div class="relative border-4 border-[var(--board-border)] rounded-lg shadow-inner overflow-hidden">
                    <!-- Board Grid (Dynamic 8x8) -->
                    <div id="chessboard" class="grid grid-cols-8 grid-rows-8 w-[84vw] h-[84vw] max-w-[500px] max-h-[500px] sm:w-[480px] sm:h-[480px]">
                        <!-- Squares dynamically created by JS -->
                    </div>
                </div>
            </div>
        </div>

        <!-- RIGHT SIDEBAR: Move Notation Log -->
        <div class="lg:col-span-3 order-3">
            <div class="bg-slate-900/90 border border-slate-800 rounded-2xl p-4 shadow-xl backdrop-blur-md h-[400px] lg:h-[540px] flex flex-col">
                <div class="flex items-center justify-between mb-3 pb-2 border-b border-slate-800">
                    <h2 class="text-xs font-bold uppercase text-slate-400 tracking-wider flex items-center gap-2">
                        <i class="fa-solid fa-list-ol text-amber-500"></i> Move History
                    </h2>
                    <span id="move-count-badge" class="text-[10px] bg-slate-800 text-slate-300 px-2 py-0.5 rounded-full font-mono">
                        0 Moves
                    </span>
                </div>

                <!-- Scrollable Move Notation Table -->
                <div class="flex-1 overflow-y-auto custom-scrollbar pr-1">
                    <table class="w-full text-xs text-left">
                        <thead class="text-slate-500 uppercase sticky top-0 bg-slate-900 pb-2 border-b border-slate-800">
                            <tr>
                                <th class="py-1 px-2 w-12">#</th>
                                <th class="py-1 px-2">White</th>
                                <th class="py-1 px-2">Black</th>
                            </tr>
                        </thead>
                        <tbody id="move-log-body" class="divide-y divide-slate-800/50 font-mono text-slate-300">
                            <!-- Rows inserted dynamically -->
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

    </main>

    <!-- FOOTER -->
    <footer class="w-full max-w-6xl mt-6 text-center text-xs text-slate-500 py-3 border-t border-slate-800/80">
        <p>The King of Chess &copy; 2026 — Designed & Developed with passion by <span class="text-amber-400 font-semibold">Dat</span></p>
    </footer>

    <!-- MODAL: Pawn Promotion -->
    <div id="promotion-modal" class="hidden fixed inset-0 bg-slate-950/80 backdrop-blur-sm z-50 flex items-center justify-center p-4">
        <div class="bg-slate-900 border-2 border-amber-500/50 rounded-2xl p-6 shadow-2xl max-w-sm w-full text-center">
            <h3 class="font-cinzel text-xl font-bold text-amber-400 mb-2">Pawn Promotion</h3>
            <p class="text-xs text-slate-300 mb-4">Select a piece to promote your pawn:</p>
            <div id="promotion-options" class="grid grid-cols-4 gap-3">
                <!-- Dynamically populated promo options -->
            </div>
        </div>
    </div>

    <!-- MODAL: Game Over -->
    <div id="gameover-modal" class="hidden fixed inset-0 bg-slate-950/85 backdrop-blur-md z-50 flex items-center justify-center p-4">
        <div class="bg-slate-900 border-2 border-amber-500 rounded-2xl p-6 sm:p-8 shadow-2xl max-w-md w-full text-center relative overflow-hidden">
            <div class="w-16 h-16 bg-gradient-to-tr from-amber-500 to-yellow-300 rounded-full flex items-center justify-center mx-auto mb-4 text-slate-950 text-3xl shadow-lg">
                <i class="fa-solid fa-trophy"></i>
            </div>
            <h2 id="gameover-title" class="font-cinzel text-2xl sm:text-3xl font-extrabold text-amber-400 mb-2">Checkmate!</h2>
            <p id="gameover-desc" class="text-sm text-slate-300 mb-6">White wins the game.</p>
            
            <div class="flex justify-center gap-3">
                <button id="modal-btn-restart" class="px-5 py-2.5 bg-gradient-to-r from-amber-500 to-amber-600 hover:from-amber-400 hover:to-amber-500 text-slate-950 font-bold rounded-xl shadow-lg transition-all transform active:scale-95 text-sm">
                    Play Again
                </button>
                <button id="modal-btn-close" class="px-5 py-2.5 bg-slate-800 hover:bg-slate-700 text-slate-300 border border-slate-700 font-semibold rounded-xl shadow transition-all text-sm">
                    View Board
                </button>
            </div>
        </div>
    </div>

    <script>
        // SVG Piece Definitions (High quality clean vectors)
        const PIECE_SVGS = {
            'w-k': `<svg viewBox="0 0 45 45" class="w-full h-full"><g fill="none" fill-rule="evenodd" stroke="#000" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M22.5 11.63V6M20 8h5" stroke-linejoin="miter"/><path d="M22.5 25c4.49 0 8-3.51 8-8 0-3.1-1.74-5.8-4.3-7.1-.63-.3-1.22-.8-1.7-1.4-.48.6-1.07 1.1-1.7 1.4-2.56 1.3-4.3 4-4.3 7.1 0 4.49 3.51 8 8 8z" fill="#fff"/><path d="M11.5 37c5.5 3.5 16.5 3.5 22 0v-7s9-4.5 6-10.5c-4-1-1-8-6-6--2-4-3.5-6-5.5-6h-7c-2 0-3.5 2-5.5 6-5 2-2 5-6 6-3 6 6 10.5 6 10.5v7z" fill="#fff"/><path d="M11.5 30c5.5-3 16.5-3 22 0M11.5 33.5c5.5-3 16.5-3 22 0M11.5 37c5.5-3 16.5-3 22 0"/></g></svg>`,
            'w-q': `<svg viewBox="0 0 45 45" class="w-full h-full"><g fill="none" fill-rule="evenodd" stroke="#000" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M8 12a2 2 0 1 1-4 0 2 2 0 0 1 4 0zm16.5-3a2 2 0 1 1-4 0 2 2 0 0 1 4 0zm16.5 3a2 2 0 1 1-4 0 2 2 0 0 1 4 0zM11 20a2 2 0 1 1-4 0 2 2 0 0 1 4 0zm25 0a2 2 0 1 1-4 0 2 2 0 0 1 4 0z"/><path d="M9 26c8.5-1.5 21.5-1.5 27 0l2-12-7 11V11l-5.5 13.5-3-15-3 15L14 11v14l-7-11 2 12z" fill="#fff"/><path d="M9 26c0 2 1.5 2 2.5 4 1 1.5 1 1.5 2.5 2h17c1.5-.5 1.5-.5 2.5-2 1-2 2.5-2 2.5-4" fill="#fff"/><path d="M11.5 30c5.5-3 16.5-3 22 0M11.5 33.5c5.5-3 16.5-3 22 0M11.5 37c5.5-3 16.5-3 22 0"/></g></svg>`,
            'w-r': `<svg viewBox="0 0 45 45" class="w-full h-full"><g fill="none" fill-rule="evenodd" stroke="#000" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M9 39h27v-3H9v3zm3-3v-4.5h21V36H12zm2-4.5c0-6.5 1.5-10.5 3-14.5h11c1.5 4 3 8 3 14.5H14z" fill="#fff"/><path d="M12 17h21v-4h-3v2h-4v-2h-3v2h-4v-2h-3v2h-4v-2h-3v4z" fill="#fff"/><path d="M11.5 30c5.5-3 16.5-3 22 0M11.5 33.5c5.5-3 16.5-3 22 0M11.5 37c5.5-3 16.5-3 22 0"/></g></svg>`,
            'w-b': `<svg viewBox="0 0 45 45" class="w-full h-full"><g fill="none" fill-rule="evenodd" stroke="#000" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><g fill="#fff" stroke-linejoin="miter"><path d="M9 36c1.2-2.7 7-3.5 13.5-3.5S34.8 33.3 36 36c-1.2 2.7-7 3.5-13.5 3.5S10.2 38.7 9 36z"/><path d="M15 32c2.5 2.5 12.5 2.5 15 0 .5-1.5 0-2 0-2 0-2.5-2.5-4-2.5-4 5.5-1.5 6-11.5-5-15.5-11 4-10.5 14-5 15.5 0 0-2.5 1.5-2.5 4 0 0-.5.5 0 2z"/><path d="M25 8a2.5 2.5 0 1 1-5 0 2.5 2.5 0 0 1 5 0z"/></g><path d="M17.5 26h10M22.5 21v10"/><path d="M22.5 10v4M11.5 37c5.5-3 16.5-3 22 0"/></g></svg>`,
            'w-n': `<svg viewBox="0 0 45 45" class="w-full h-full"><g fill="none" fill-rule="evenodd" stroke="#000" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M22 10c10.5 1 16.5 8 16 29H15c0-9 10-6.5 8-12-1-2.5-3-2.5-6-2-2.5 1-4 2.5-6 1.5-1.5-1-1.5-3-1-4.5 1.5-2.5 5-2.5 7-.5 1.5 1.5 2.5 1 1-1.5-1-1.5-3-2-4.5-1.5-1.5.5-2 1.5-2 3 0 2.5 2 4.5 3.5 6.5.5 1 1.5 1 2.5 0 3.5-3 8-4.5 11.5-5z" fill="#fff"/><path d="M24 18c.38 2.91-5.55 7.37-8 9-.53.35-1.08.7-1.63 1.05M11.5 37c5.5-3 16.5-3 22 0M11.5 33.5c5.5-3 16.5-3 22 0"/></g></svg>`,
            'w-p': `<svg viewBox="0 0 45 45" class="w-full h-full"><g fill="none" fill-rule="evenodd" stroke="#000" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M22 9c-2.21 0-4 1.79-4 4 0 .89.29 1.71.78 2.38-1.95 1.12-3.28 3.21-3.28 5.62 0 2.03.94 3.84 2.41 5.03-3 1.06-7.41 5.55-7.41 13.47h23c0-7.92-4.41-12.41-7.41-13.47 1.47-1.19 2.41-3 2.41-5.03 0-2.41-1.33-4.5-3.28-5.62.49-.67.78-1.49.78-2.38 0-2.21-1.79-4-4-4z" fill="#fff"/></g></svg>`,
            
            'b-k': `<svg viewBox="0 0 45 45" class="w-full h-full"><g fill="none" fill-rule="evenodd" stroke="#000" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M22.5 11.63V6M20 8h5" stroke-linejoin="miter"/><path d="M22.5 25c4.49 0 8-3.51 8-8 0-3.1-1.74-5.8-4.3-7.1-.63-.3-1.22-.8-1.7-1.4-.48.6-1.07 1.1-1.7 1.4-2.56 1.3-4.3 4-4.3 7.1 0 4.49 3.51 8 8 8z" fill="#333"/><path d="M11.5 37c5.5 3.5 16.5 3.5 22 0v-7s9-4.5 6-10.5c-4-1-1-8-6-6--2-4-3.5-6-5.5-6h-7c-2 0-3.5 2-5.5 6-5 2-2 5-6 6-3 6 6 10.5 6 10.5v7z" fill="#333"/><path d="M11.5 30c5.5-3 16.5-3 22 0 stroke="#fff""/><path d="M11.5 33.5c5.5-3 16.5-3 22 0" stroke="#fff"/><path d="M11.5 37c5.5-3 16.5-3 22 0" stroke="#fff"/></g></svg>`,
            'b-q': `<svg viewBox="0 0 45 45" class="w-full h-full"><g fill="none" fill-rule="evenodd" stroke="#000" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M8 12a2 2 0 1 1-4 0 2 2 0 0 1 4 0zm16.5-3a2 2 0 1 1-4 0 2 2 0 0 1 4 0zm16.5 3a2 2 0 1 1-4 0 2 2 0 0 1 4 0zM11 20a2 2 0 1 1-4 0 2 2 0 0 1 4 0zm25 0a2 2 0 1 1-4 0 2 2 0 0 1 4 0z"/><path d="M9 26c8.5-1.5 21.5-1.5 27 0l2-12-7 11V11l-5.5 13.5-3-15-3 15L14 11v14l-7-11 2 12z" fill="#333"/><path d="M9 26c0 2 1.5 2 2.5 4 1 1.5 1 1.5 2.5 2h17c1.5-.5 1.5-.5 2.5-2 1-2 2.5-2 2.5-4" fill="#333"/><path d="M11.5 30c5.5-3 16.5-3 22 0" stroke="#fff"/><path d="M11.5 33.5c5.5-3 16.5-3 22 0" stroke="#fff"/><path d="M11.5 37c5.5-3 16.5-3 22 0" stroke="#fff"/></g></svg>`,
            'b-r': `<svg viewBox="0 0 45 45" class="w-full h-full"><g fill="none" fill-rule="evenodd" stroke="#000" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M9 39h27v-3H9v3zm3-3v-4.5h21V36H12zm2-4.5c0-6.5 1.5-10.5 3-14.5h11c1.5 4 3 8 3 14.5H14z" fill="#333"/><path d="M12 17h21v-4h-3v2h-4v-2h-3v2h-4v-2h-3v2h-4v-2h-3v4z" fill="#333"/><path d="M11.5 30c5.5-3 16.5-3 22 0" stroke="#fff"/><path d="M11.5 33.5c5.5-3 16.5-3 22 0" stroke="#fff"/><path d="M11.5 37c5.5-3 16.5-3 22 0" stroke="#fff"/></g></svg>`,
            'b-b': `<svg viewBox="0 0 45 45" class="w-full h-full"><g fill="none" fill-rule="evenodd" stroke="#000" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><g fill="#333" stroke-linejoin="miter"><path d="M9 36c1.2-2.7 7-3.5 13.5-3.5S34.8 33.3 36 36c-1.2 2.7-7 3.5-13.5 3.5S10.2 38.7 9 36z"/><path d="M15 32c2.5 2.5 12.5 2.5 15 0 .5-1.5 0-2 0-2 0-2.5-2.5-4-2.5-4 5.5-1.5 6-11.5-5-15.5-11 4-10.5 14-5 15.5 0 0-2.5 1.5-2.5 4 0 0-.5.5 0 2z"/><path d="M25 8a2.5 2.5 0 1 1-5 0 2.5 2.5 0 0 1 5 0z"/></g><path d="M17.5 26h10M22.5 21v10" stroke="#fff"/><path d="M22.5 10v4M11.5 37c5.5-3 16.5-3 22 0" stroke="#fff"/></g></svg>`,
            'b-n': `<svg viewBox="0 0 45 45" class="w-full h-full"><g fill="none" fill-rule="evenodd" stroke="#000" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M22 10c10.5 1 16.5 8 16 29H15c0-9 10-6.5 8-12-1-2.5-3-2.5-6-2-2.5 1-4 2.5-6 1.5-1.5-1-1.5-3-1-4.5 1.5-2.5 5-2.5 7-.5 1.5 1.5 2.5 1 1-1.5-1-1.5-3-2-4.5-1.5-1.5.5-2 1.5-2 3 0 2.5 2 4.5 3.5 6.5.5 1 1.5 1 2.5 0 3.5-3 8-4.5 11.5-5z" fill="#333"/><path d="M24 18c.38 2.91-5.55 7.37-8 9-.53.35-1.08.7-1.63 1.05" stroke="#fff"/><path d="M11.5 37c5.5-3 16.5-3 22 0" stroke="#fff"/><path d="M11.5 33.5c5.5-3 16.5-3 22 0" stroke="#fff"/></g></svg>`,
            'b-p': `<svg viewBox="0 0 45 45" class="w-full h-full"><g fill="none" fill-rule="evenodd" stroke="#000" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M22 9c-2.21 0-4 1.79-4 4 0 .89.29 1.71.78 2.38-1.95 1.12-3.28 3.21-3.28 5.62 0 2.03.94 3.84 2.41 5.03-3 1.06-7.41 5.55-7.41 13.47h23c0-7.92-4.41-12.41-7.41-13.47 1.47-1.19 2.41-3 2.41-5.03 0-2.41-1.33-4.5-3.28-5.62.49-.67.78-1.49.78-2.38 0-2.21-1.79-4-4-4z" fill="#333"/></g></svg>`
        };

        // Audio Synthesizer (No external audio files required)
        class SoundEngine {
            constructor() {
                this.ctx = null;
                this.muted = false;
            }

            init() {
                if (!this.ctx) {
                    const AudioContext = window.AudioContext || window.webkitAudioContext;
                    if (AudioContext) this.ctx = new AudioContext();
                }
            }

            playMove() {
                if (this.muted || !this.ctx) return;
                try {
                    const osc = this.ctx.createOscillator();
                    const gain = this.ctx.createGain();
                    osc.type = 'sine';
                    osc.frequency.setValueAtTime(320, this.ctx.currentTime);
                    osc.frequency.exponentialRampToValueAtTime(140, this.ctx.currentTime + 0.08);
                    gain.gain.setValueAtTime(0.3, this.ctx.currentTime);
                    gain.gain.exponentialRampToValueAtTime(0.01, this.ctx.currentTime + 0.08);
                    osc.connect(gain);
                    gain.connect(this.ctx.destination);
                    osc.start();
                    osc.stop(this.ctx.currentTime + 0.08);
                } catch (e) {}
            }

            playCapture() {
                if (this.muted || !this.ctx) return;
                try {
                    const osc = this.ctx.createOscillator();
                    const gain = this.ctx.createGain();
                    osc.type = 'triangle';
                    osc.frequency.setValueAtTime(180, this.ctx.currentTime);
                    osc.frequency.exponentialRampToValueAtTime(60, this.ctx.currentTime + 0.12);
                    gain.gain.setValueAtTime(0.5, this.ctx.currentTime);
                    gain.gain.exponentialRampToValueAtTime(0.01, this.ctx.currentTime + 0.12);
                    osc.connect(gain);
                    gain.connect(this.ctx.destination);
                    osc.start();
                    osc.stop(this.ctx.currentTime + 0.12);
                } catch (e) {}
            }

            playCheck() {
                if (this.muted || !this.ctx) return;
                try {
                    const now = this.ctx.currentTime;
                    const osc1 = this.ctx.createOscillator();
                    const gain1 = this.ctx.createGain();
                    osc1.type = 'sine';
                    osc1.frequency.setValueAtTime(587.33, now); // D5
                    gain1.gain.setValueAtTime(0.25, now);
                    gain1.gain.exponentialRampToValueAtTime(0.01, now + 0.2);
                    osc1.connect(gain1);
                    gain1.connect(this.ctx.destination);
                    osc1.start(now);
                    osc1.stop(now + 0.2);
                } catch (e) {}
            }

            playGameEnd() {
                if (this.muted || !this.ctx) return;
                try {
                    const now = this.ctx.currentTime;
                    [523.25, 659.25, 783.99, 1046.50].forEach((freq, idx) => {
                        const osc = this.ctx.createOscillator();
                        const gain = this.ctx.createGain();
                        osc.type = 'triangle';
                        osc.frequency.setValueAtTime(freq, now + idx * 0.1);
                        gain.gain.setValueAtTime(0.2, now + idx * 0.1);
                        gain.gain.exponentialRampToValueAtTime(0.01, now + idx * 0.1 + 0.3);
                        osc.connect(gain);
                        gain.connect(this.ctx.destination);
                        osc.start(now + idx * 0.1);
                        osc.stop(now + idx * 0.1 + 0.3);
                    });
                } catch (e) {}
            }
        }

        const sound = new SoundEngine();

        // Game State Variables
        let board = [];
        let currentTurn = 'w';
        let selectedSquare = null;
        let legalMoves = [];
        let moveHistory = [];
        let capturedPieces = { w: [], b: [] };
        let isBoardFlipped = false;
        let gameMode = 'ai-medium';
        let playerColor = 'w';
        let isGameOver = false;
        let enPassantTarget = null; // { r, c }
        let castlingRights = {
            w: { k: true, q: true },
            b: { k: true, q: true }
        };
        let timerW = 600;
        let timerB = 600;
        let timerInterval = null;
        let pendingPromotion = null;

        // Piece Positional Values for AI (Piece-Square Tables)
        const pawnTable = [
            [0,  0,  0,  0,  0,  0,  0,  0],
            [50, 50, 50, 50, 50, 50, 50, 50],
            [10, 10, 20, 30, 30, 20, 10, 10],
            [ 5,  5, 10, 27, 27, 10,  5,  5],
            [ 0,  0,  0, 24, 24,  0,  0,  0],
            [ 5, -5,-10,  0,  0,-10, -5,  5],
            [ 5, 10, 10,-25,-25, 10, 10,  5],
            [ 0,  0,  0,  0,  0,  0,  0,  0]
        ];

        const knightTable = [
            [-50,-40,-30,-30,-30,-30,-40,-50],
            [-40,-20,  0,  0,  0,  0,-20,-40],
            [-30,  0, 10, 15, 15, 10,  0,-30],
            [-30,  5, 15, 20, 20, 15,  5,-30],
            [-30,  0, 15, 20, 20, 15,  0,-30],
            [-30,  5, 10, 15, 15, 10,  5,-30],
            [-40,-20,  0,  5,  5,  0,-20,-40],
            [-50,-40,-30,-30,-30,-30,-40,-50]
        ];

        const bishopTable = [
            [-20,-10,-10,-10,-10,-10,-10,-20],
            [-10,  0,  0,  0,  0,  0,  0,-10],
            [-10,  0,  5, 10, 10,  5,  0,-10],
            [-10,  5,  5, 10, 10,  5,  5,-10],
            [-10,  0, 10, 10, 10, 10,  0,-10],
            [-10, 10, 10, 10, 10, 10, 10,-10],
            [-10,  5,  0,  0,  0,  0,  5,-10],
            [-20,-10,-10,-10,-10,-10,-10,-20]
        ];

        const rookTable = [
            [ 0,  0,  0,  0,  0,  0,  0,  0],
            [ 5, 10, 10, 10, 10, 10, 10,  5],
            [-5,  0,  0,  0,  0,  0,  0, -5],
            [-5,  0,  0,  0,  0,  0,  0, -5],
            [-5,  0,  0,  0,  0,  0,  0, -5],
            [-5,  0,  0,  0,  0,  0,  0, -5],
            [-5,  0,  0,  0,  0,  0,  0, -5],
            [ 0,  0,  0,  5,  5,  0,  0,  0]
        ];

        // Initialize Standard Board Layout
        function initBoard() {
            board = Array(8).fill(null).map(() => Array(8).fill(null));
            const setup = ['r', 'n', 'b', 'q', 'k', 'b', 'n', 'r'];
            
            for (let c = 0; c < 8; c++) {
                board[0][c] = { type: setup[c], color: 'b' };
                board[1][c] = { type: 'p', color: 'b' };
                board[6][c] = { type: 'p', color: 'w' };
                board[7][c] = { type: setup[c], color: 'w' };
            }

            currentTurn = 'w';
            selectedSquare = null;
            legalMoves = [];
            moveHistory = [];
            capturedPieces = { w: [], b: [] };
            enPassantTarget = null;
            castlingRights = {
                w: { k: true, q: true },
                b: { k: true, q: true }
            };
            isGameOver = false;
            timerW = 600;
            timerB = 600;
            startTimer();
        }

        // Deep copy board helper
        function cloneBoard(b) {
            return b.map(row => row.map(cell => cell ? { ...cell } : null));
        }

        // Get pseudo-legal moves for a piece on a given board
        function getPseudoMoves(r, c, bState = board, castlingCheck = true) {
            const piece = bState[r][c];
            if (!piece) return [];
            const moves = [];
            const color = piece.color;
            const enemyColor = color === 'w' ? 'b' : 'w';
            const dir = color === 'w' ? -1 : 1;

            switch (piece.type) {
                case 'p':
                    // Single step forward
                    if (r + dir >= 0 && r + dir < 8 && !bState[r + dir][c]) {
                        moves.push({ from: { r, c }, to: { r: r + dir, c } });
                        // Double step forward
                        const startRank = color === 'w' ? 6 : 1;
                        if (r === startRank && !bState[r + 2 * dir][c]) {
                            moves.push({ from: { r, c }, to: { r: r + 2 * dir, c }, isDoublePawn: true });
                        }
                    }
                    // Diagonal Captures
                    for (let dc of [-1, 1]) {
                        const nr = r + dir, nc = c + dc;
                        if (nr >= 0 && nr < 8 && nc >= 0 && nc < 8) {
                            if (bState[nr][nc] && bState[nr][nc].color === enemyColor) {
                                moves.push({ from: { r, c }, to: { r: nr, c: nc } });
                            }
                            // En Passant Capture
                            if (enPassantTarget && enPassantTarget.r === nr && enPassantTarget.c === nc) {
                                moves.push({ from: { r, c }, to: { r: nr, c: nc }, isEnPassant: true });
                            }
                        }
                    }
                    break;

                case 'n':
                    const knightOffsets = [
                        [-2, -1], [-2, 1], [-1, -2], [-1, 2],
                        [1, -2], [1, 2], [2, -1], [2, 1]
                    ];
                    for (let [dr, dc] of knightOffsets) {
                        const nr = r + dr, nc = c + dc;
                        if (nr >= 0 && nr < 8 && nc >= 0 && nc < 8) {
                            if (!bState[nr][nc] || bState[nr][nc].color === enemyColor) {
                                moves.push({ from: { r, c }, to: { r: nr, c: nc } });
                            }
                        }
                    }
                    break;

                case 'b':
                case 'r':
                case 'q':
                    let dirs = [];
                    if (piece.type === 'b' || piece.type === 'q') dirs.push([-1, -1], [-1, 1], [1, -1], [1, 1]);
                    if (piece.type === 'r' || piece.type === 'q') dirs.push([-1, 0], [1, 0], [0, -1], [0, 1]);

                    for (let [dr, dc] of dirs) {
                        let nr = r + dr, nc = c + dc;
                        while (nr >= 0 && nr < 8 && nc >= 0 && nc < 8) {
                            if (!bState[nr][nc]) {
                                moves.push({ from: { r, c }, to: { r: nr, c: nc } });
                            } else {
                                if (bState[nr][nc].color === enemyColor) {
                                    moves.push({ from: { r, c }, to: { r: nr, c: nc } });
                                }
                                break;
                            }
                            nr += dr;
                            nc += dc;
                        }
                    }
                    break;

                case 'k':
                    const kingOffsets = [
                        [-1, -1], [-1, 0], [-1, 1],
                        [0, -1],          [0, 1],
                        [1, -1],  [1, 0],  [1, 1]
                    ];
                    for (let [dr, dc] of kingOffsets) {
                        const nr = r + dr, nc = c + dc;
                        if (nr >= 0 && nr < 8 && nc >= 0 && nc < 8) {
                            if (!bState[nr][nc] || bState[nr][nc].color === enemyColor) {
                                moves.push({ from: { r, c }, to: { r: nr, c: nc } });
                            }
                        }
                    }

                    // Castling Logic
                    if (castlingCheck) {
                        const rights = castlingRights[color];
                        const rank = color === 'w' ? 7 : 0;
                        if (r === rank && c === 4) {
                            // Kingside
                            if (rights.k && !bState[rank][5] && !bState[rank][6]) {
                                if (!isSquareAttacked(rank, 4, enemyColor, bState) &&
                                    !isSquareAttacked(rank, 5, enemyColor, bState) &&
                                    !isSquareAttacked(rank, 6, enemyColor, bState)) {
                                    moves.push({ from: { r, c }, to: { r: rank, c: 6 }, isCastleK: true });
                                }
                            }
                            // Queenside
                            if (rights.q && !bState[rank][1] && !bState[rank][2] && !bState[rank][3]) {
                                if (!isSquareAttacked(rank, 4, enemyColor, bState) &&
                                    !isSquareAttacked(rank, 3, enemyColor, bState) &&
                                    !isSquareAttacked(rank, 2, enemyColor, bState)) {
                                    moves.push({ from: { r, c }, to: { r: rank, c: 2 }, isCastleQ: true });
                                }
                            }
                        }
                    }
                    break;
            }
            return moves;
        }

        // Check if square is under attack by opponent
        function isSquareAttacked(r, c, attackerColor, bState = board) {
            for (let row = 0; row < 8; row++) {
                for (let col = 0; col < 8; col++) {
                    const p = bState[row][col];
                    if (p && p.color === attackerColor) {
                        const pMoves = getPseudoMoves(row, col, bState, false);
                        if (pMoves.some(m => m.to.r === r && m.to.c === c)) return true;
                    }
                }
            }
            return false;
        }

        // Find position of King
        function findKing(color, bState = board) {
            for (let r = 0; r < 8; r++) {
                for (let c = 0; c < 8; c++) {
                    if (bState[r][c] && bState[r][c].type === 'k' && bState[r][c].color === color) {
                        return { r, c };
                    }
                }
            }
            return null;
        }

        // Check if King of specified color is in check
        function isInCheck(color, bState = board) {
            const kingPos = findKing(color, bState);
            if (!kingPos) return false;
            const enemyColor = color === 'w' ? 'b' : 'w';
            return isSquareAttacked(kingPos.r, kingPos.c, enemyColor, bState);
        }

        // Filter pseudo moves to return only strictly legal moves (prevent self-check)
        function getLegalMoves(r, c, bState = board) {
            const piece = bState[r][c];
            if (!piece || piece.color !== currentTurn) return [];

            const pseudo = getPseudoMoves(r, c, bState, true);
            return pseudo.filter(move => {
                const tempBoard = cloneBoard(bState);
                executeSimulatedMove(tempBoard, move);
                return !isInCheck(piece.color, tempBoard);
            });
        }

        // Execute move on temporary state without triggers
        function executeSimulatedMove(bState, move) {
            const { from, to, isEnPassant, isCastleK, isCastleQ } = move;
            const piece = bState[from.r][from.c];

            bState[to.r][to.c] = piece;
            bState[from.r][from.c] = null;

            if (isEnPassant) {
                const capRank = piece.color === 'w' ? to.r + 1 : to.r - 1;
                bState[capRank][to.c] = null;
            } else if (isCastleK) {
                const rook = bState[from.r][7];
                bState[from.r][5] = rook;
                bState[from.r][7] = null;
            } else if (isCastleQ) {
                const rook = bState[from.r][0];
                bState[from.r][3] = rook;
                bState[from.r][0] = null;
            }
        }

        // Get all legal moves for current player
        function getAllLegalMoves(color = currentTurn, bState = board) {
            let moves = [];
            for (let r = 0; r < 8; r++) {
                for (let c = 0; c < 8; c++) {
                    if (bState[r][c] && bState[r][c].color === color) {
                        const m = getLegalMoves(r, c, bState);
                        moves.push(...m);
                    }
                }
            }
            return moves;
        }

        // Make move on main board state
        function makeMove(move, promoChoice = null) {
            const { from, to, isEnPassant, isCastleK, isCastleQ, isDoublePawn } = move;
            const piece = board[from.r][from.c];
            const captured = board[to.r][to.c];

            // Save history snapshot for Undo
            moveHistory.push({
                board: cloneBoard(board),
                turn: currentTurn,
                castlingRights: JSON.parse(JSON.stringify(castlingRights)),
                enPassantTarget: enPassantTarget ? { ...enPassantTarget } : null,
                capturedPieces: { w: [...capturedPieces.w], b: [...capturedPieces.b] },
                move
            });

            // Handle captures & audio
            let hasCaptured = false;
            if (captured) {
                capturedPieces[captured.color].push(captured.type);
                hasCaptured = true;
            } else if (isEnPassant) {
                const capRank = piece.color === 'w' ? to.r + 1 : to.r - 1;
                const enP = board[capRank][to.c];
                capturedPieces[enP.color].push(enP.type);
                board[capRank][to.c] = null;
                hasCaptured = true;
            }

            // Update board
            board[to.r][to.c] = piece;
            board[from.r][from.c] = null;

            // Handle Castling
            if (isCastleK) {
                board[from.r][5] = board[from.r][7];
                board[from.r][7] = null;
            } else if (isCastleQ) {
                board[from.r][3] = board[from.r][0];
                board[from.r][0] = null;
            }

            // Handle Pawn Promotion Check
            const promoRank = piece.color === 'w' ? 0 : 7;
            if (piece.type === 'p' && to.r === promoRank) {
                if (promoChoice) {
                    board[to.r][to.c].type = promoChoice;
                } else if (gameMode.startsWith('ai') && currentTurn !== playerColor) {
                    board[to.r][to.c].type = 'q'; // AI auto promotes to Queen
                } else {
                    // Revert temporarily to request player modal choice
                    moveHistory.pop();
                    board[from.r][from.c] = piece;
                    board[to.r][to.c] = captured;
                    if (isEnPassant) {
                        const capRank = piece.color === 'w' ? to.r + 1 : to.r - 1;
                        board[capRank][to.c] = { type: 'p', color: currentTurn === 'w' ? 'b' : 'w' };
                    }
                    showPromotionModal(move);
                    return;
                }
            }

            // Update Castling Rights
            if (piece.type === 'k') {
                castlingRights[piece.color].k = false;
                castlingRights[piece.color].q = false;
            } else if (piece.type === 'r') {
                if (from.r === 7 && from.c === 0) castlingRights.w.q = false;
                if (from.r === 7 && from.c === 7) castlingRights.w.k = false;
                if (from.r === 0 && from.c === 0) castlingRights.b.q = false;
                if (from.r === 0 && from.c === 7) castlingRights.b.k = false;
            }

            // Update En Passant Target
            if (isDoublePawn) {
                enPassantTarget = { r: (from.r + to.r) / 2, c: from.c };
            } else {
                enPassantTarget = null;
            }

            // Sound Effects
            if (hasCaptured) {
                sound.playCapture();
            } else {
                sound.playMove();
            }

            // Switch Turn
            currentTurn = currentTurn === 'w' ? 'b' : 'w';
            selectedSquare = null;
            legalMoves = [];

            // Game State Validation (Check, Checkmate, Stalemate)
            const kingInCheck = isInCheck(currentTurn);
            const legalMovesNext = getAllLegalMoves(currentTurn);

            if (kingInCheck) {
                if (legalMovesNext.length === 0) {
                    endGame('checkmate');
                } else {
                    sound.playCheck();
                    updateStatus(`CHECK! ${currentTurn === 'w' ? 'White' : 'Black'}'s King is under attack!`);
                }
            } else if (legalMovesNext.length === 0) {
                endGame('stalemate');
            } else {
                updateStatus(`${currentTurn === 'w' ? "White" : "Black"}'s turn to move`);
            }

            render();

            // AI Move Trigger
            if (!isGameOver && gameMode.startsWith('ai') && currentTurn !== playerColor) {
                setTimeout(makeAIMove, 300);
            }
        }

        // Show Pawn Promotion Modal
        function showPromotionModal(move) {
            pendingPromotion = move;
            const container = document.getElementById('promotion-options');
            container.innerHTML = '';
            const pieces = ['q', 'r', 'b', 'n'];
            
            pieces.forEach(p => {
                const btn = document.createElement('button');
                btn.className = 'p-3 bg-slate-800 hover:bg-amber-500/20 border border-slate-700 hover:border-amber-500 rounded-xl flex items-center justify-center transition-all transform hover:scale-105';
                btn.innerHTML = `<div class="w-10 h-10">${PIECE_SVGS[currentTurn + '-' + p]}</div>`;
                btn.onclick = () => {
                    document.getElementById('promotion-modal').classList.add('hidden');
                    makeMove(pendingPromotion, p);
                    pendingPromotion = null;
                };
                container.appendChild(btn);
            });

            document.getElementById('promotion-modal').classList.remove('hidden');
        }

        // Undo Previous Move
        function undoMove() {
            if (moveHistory.length === 0 || isGameOver) return;
            
            // Undo 2 steps if playing against AI, 1 step for PvP
            let steps = (gameMode.startsWith('ai') && moveHistory.length >= 2) ? 2 : 1;
            
            while (steps > 0 && moveHistory.length > 0) {
                const prev = moveHistory.pop();
                board = prev.board;
                currentTurn = prev.turn;
                castlingRights = prev.castlingRights;
                enPassantTarget = prev.enPassantTarget;
                capturedPieces = prev.capturedPieces;
                steps--;
            }

            selectedSquare = null;
            legalMoves = [];
            isGameOver = false;
            updateStatus(`${currentTurn === 'w' ? "White" : "Black"}'s turn to move`);
            render();
        }

        // AI Logic Engine
        function makeAIMove() {
            if (isGameOver) return;

            const moves = getAllLegalMoves(currentTurn);
            if (moves.length === 0) return;

            let chosenMove = null;

            if (gameMode === 'ai-easy') {
                // Random move selector for Easy AI
                chosenMove = moves[Math.floor(Math.random() * moves.length)];
            } else {
                // Minimax with Alpha-Beta Pruning for Medium AI
                chosenMove = getBestMoveMinimax(2);
            }

            if (chosenMove) {
                makeMove(chosenMove);
            }
        }

        // Minimax Root Call
        function getBestMoveMinimax(depth) {
            const moves = getAllLegalMoves(currentTurn);
            let bestMove = null;
            let bestEval = currentTurn === 'w' ? -Infinity : Infinity;

            // Shuffle moves to avoid predictable play
            moves.sort(() => Math.random() - 0.5);

            for (const move of moves) {
                const tempBoard = cloneBoard(board);
                executeSimulatedMove(tempBoard, move);

                const evaluation = minimax(tempBoard, depth - 1, -Infinity, Infinity, currentTurn !== 'w');

                if (currentTurn === 'w') {
                    if (evaluation > bestEval) {
                        bestEval = evaluation;
                        bestMove = move;
                    }
                } else {
                    if (evaluation < bestEval) {
                        bestEval = evaluation;
                        bestMove = move;
                    }
                }
            }

            return bestMove || moves[0];
        }

        // Minimax Recursion with Alpha-Beta
        function minimax(bState, depth, alpha, beta, isMaximizing) {
            if (depth === 0) {
                return evaluateBoard(bState);
            }

            const activeColor = isMaximizing ? 'w' : 'b';
            const moves = getAllLegalMoves(activeColor, bState);

            if (moves.length === 0) {
                if (isInCheck(activeColor, bState)) {
                    return isMaximizing ? -100000 : 100000;
                }
                return 0; // Stalemate
            }

            if (isMaximizing) {
                let maxEval = -Infinity;
                for (const move of moves) {
                    const temp = cloneBoard(bState);
                    executeSimulatedMove(temp, move);
                    const evalVal = minimax(temp, depth - 1, alpha, beta, false);
                    maxEval = Math.max(maxEval, evalVal);
                    alpha = Math.max(alpha, evalVal);
                    if (beta <= alpha) break;
                }
                return maxEval;
            } else {
                let minEval = Infinity;
                for (const move of moves) {
                    const temp = cloneBoard(bState);
                    executeSimulatedMove(temp, move);
                    const evalVal = minimax(temp, depth - 1, alpha, beta, true);
                    minEval = Math.min(minEval, evalVal);
                    beta = Math.min(beta, evalVal);
                    if (beta <= alpha) break;
                }
                return minEval;
            }
        }

        // Static Board Evaluation Function
        function evaluateBoard(bState) {
            const pieceValues = { p: 100, n: 320, b: 330, r: 500, q: 900, k: 20000 };
            let totalEval = 0;

            for (let r = 0; r < 8; r++) {
                for (let c = 0; c < 8; c++) {
                    const piece = bState[r][c];
                    if (piece) {
                        let val = pieceValues[piece.type];
                        let posVal = 0;

                        // Add positional heuristic tables
                        if (piece.type === 'p') posVal = piece.color === 'w' ? pawnTable[r][c] : pawnTable[7 - r][c];
                        if (piece.type === 'n') posVal = knightTable[r][c];
                        if (piece.type === 'b') posVal = bishopTable[r][c];
                        if (piece.type === 'r') posVal = rookTable[r][c];

                        const score = val + posVal;
                        totalEval += piece.color === 'w' ? score : -score;
                    }
                }
            }

            return totalEval;
        }

        // Game Timer Management
        function startTimer() {
            clearInterval(timerInterval);
            timerInterval = setInterval(() => {
                if (isGameOver) return;
                if (currentTurn === 'w') {
                    timerW--;
                    if (timerW <= 0) endGame('timeout', 'b');
                } else {
                    timerB--;
                    if (timerB <= 0) endGame('timeout', 'w');
                }
                updateTimersDisplay();
            }, 1000);
        }

        function updateTimersDisplay() {
            const fmt = (s) => {
                const m = Math.floor(s / 60);
                const sec = s % 60;
                return `${m}:${sec < 10 ? '0' : ''}${sec}`;
            };
            document.getElementById('timer-w').innerText = fmt(timerW);
            document.getElementById('timer-b').innerText = fmt(timerB);
        }

        // End Game Overlay Handler
        function endGame(reason, winnerColor = null) {
            isGameOver = true;
            clearInterval(timerInterval);
            sound.playGameEnd();

            const modal = document.getElementById('gameover-modal');
            const title = document.getElementById('gameover-title');
            const desc = document.getElementById('gameover-desc');

            if (reason === 'checkmate') {
                const winner = currentTurn === 'w' ? 'Black' : 'White';
                title.innerText = 'CHECKMATE!';
                desc.innerText = `${winner} wins by Checkmate!`;
                updateStatus(`GAME OVER — ${winner.toUpperCase()} WINS!`);
            } else if (reason === 'stalemate') {
                title.innerText = 'STALEMATE!';
                desc.innerText = 'The game ended in a draw (Stalemate).';
                updateStatus('GAME OVER — DRAW BY STALEMATE');
            } else if (reason === 'timeout') {
                const winner = winnerColor === 'w' ? 'White' : 'Black';
                title.innerText = 'TIME OUT!';
                desc.innerText = `${winner} wins on time!`;
                updateStatus(`GAME OVER — ${winner.toUpperCase()} WINS ON TIME!`);
            }

            modal.classList.remove('hidden');
        }

        // Status Banner Updater
        function updateStatus(text) {
            document.getElementById('status-text').innerText = text;
        }

        // Coordinate Convertors
        function getAlgebraic(r, c) {
            const files = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'];
            return `${files[c]}${8 - r}`;
        }

        // Render UI, Chessboard, Captured Pieces, Move History Log
        function render() {
            const boardEl = document.getElementById('chessboard');
            boardEl.innerHTML = '';

            const kingInCheckPos = isInCheck(currentTurn) ? findKing(currentTurn) : null;
            const lastMove = moveHistory.length > 0 ? moveHistory[moveHistory.length - 1].move : null;

            for (let rDisplay = 0; rDisplay < 8; rDisplay++) {
                for (let cDisplay = 0; cDisplay < 8; cDisplay++) {
                    const r = isBoardFlipped ? 7 - rDisplay : rDisplay;
                    const c = isBoardFlipped ? 7 - cDisplay : cDisplay;

                    const square = document.createElement('div');
                    const isLight = (r + c) % 2 === 0;
                    
                    square.className = `chess-square relative flex items-center justify-center ${isLight ? 'square-light' : 'square-dark'}`;
                    square.dataset.row = r;
                    square.dataset.col = c;

                    // Highlight selected square
                    if (selectedSquare && selectedSquare.r === r && selectedSquare.c === c) {
                        square.classList.add('square-selected');
                    }

                    // Highlight last move squares
                    if (lastMove && ((lastMove.from.r === r && lastMove.from.c === c) || (lastMove.to.r === r && lastMove.to.c === c))) {
                        square.classList.add('square-last-move');
                    }

                    // Highlight king in check
                    if (kingInCheckPos && kingInCheckPos.r === r && kingInCheckPos.c === c) {
                        square.classList.add('square-in-check');
                    }

                    // Add Coordinate Labels on Edges
                    if (cDisplay === 0) {
                        const rankLabel = document.createElement('span');
                        rankLabel.className = 'absolute top-0.5 left-1 text-[9px] font-bold opacity-70 pointer-events-none';
                        rankLabel.innerText = 8 - r;
                        square.appendChild(rankLabel);
                    }
                    if (rDisplay === 7) {
                        const fileLabel = document.createElement('span');
                        fileLabel.className = 'absolute bottom-0.5 right-1 text-[9px] font-bold opacity-70 pointer-events-none';
                        fileLabel.innerText = String.fromCharCode(97 + c);
                        square.appendChild(fileLabel);
                    }

                    // Highlight Legal Moves Target Indicators
                    const legalTarget = legalMoves.find(m => m.to.r === r && m.to.c === c);
                    if (legalTarget) {
                        const indicator = document.createElement('div');
                        indicator.className = board[r][c] ? 'capture-indicator' : 'move-indicator';
                        square.appendChild(indicator);
                    }

                    // Render Piece Graphic
                    const piece = board[r][c];
                    if (piece) {
                        const pieceDiv = document.createElement('div');
                        pieceDiv.className = 'w-[80%] h-[80%] piece-img flex items-center justify-center';
                        pieceDiv.draggable = true;
                        pieceDiv.innerHTML = PIECE_SVGS[`${piece.color}-${piece.type}`];

                        // Drag & Drop Handlers
                        pieceDiv.addEventListener('dragstart', (e) => {
                            if (isGameOver) return e.preventDefault();
                            if (gameMode.startsWith('ai') && currentTurn !== playerColor) return e.preventDefault();
                            if (piece.color !== currentTurn) return e.preventDefault();

                            sound.init();
                            selectedSquare = { r, c };
                            legalMoves = getLegalMoves(r, c);
                            pieceDiv.classList.add('piece-dragging');
                            e.dataTransfer.setData('text/plain', JSON.stringify({ r, c }));
                            render();
                        });

                        pieceDiv.addEventListener('dragend', () => {
                            pieceDiv.classList.remove('piece-dragging');
                        });

                        square.appendChild(pieceDiv);
                    }

                    // Click & Drag-Over Event Handlers
                    square.addEventListener('dragover', (e) => e.preventDefault());
                    
                    square.addEventListener('drop', (e) => {
                        e.preventDefault();
                        if (isGameOver) return;
                        const data = e.dataTransfer.getData('text/plain');
                        if (!data) return;
                        const fromPos = JSON.parse(data);
                        const move = legalMoves.find(m => m.to.r === r && m.to.c === c);
                        if (move) {
                            makeMove(move);
                        }
                    });

                    square.addEventListener('click', () => {
                        if (isGameOver) return;
                        if (gameMode.startsWith('ai') && currentTurn !== playerColor) return;

                        sound.init();

                        if (selectedSquare) {
                            const move = legalMoves.find(m => m.to.r === r && m.to.c === c);
                            if (move) {
                                makeMove(move);
                                return;
                            }
                        }

                        if (piece && piece.color === currentTurn) {
                            selectedSquare = { r, c };
                            legalMoves = getLegalMoves(r, c);
                        } else {
                            selectedSquare = null;
                            legalMoves = [];
                        }
                        render();
                    });

                    boardEl.appendChild(square);
                }
            }

            // Render Active Player Badges
            document.getElementById('badge-turn-w').style.display = currentTurn === 'w' ? 'inline-block' : 'none';
            document.getElementById('badge-turn-b').style.display = currentTurn === 'b' ? 'inline-block' : 'none';

            // Render Captured Pieces Display
            renderCapturedPieces();

            // Render Move History Notation Log
            renderMoveHistory();
        }

        // Render Captured Pieces List
        function renderCapturedPieces() {
            const capWEl = document.getElementById('captured-w');
            const capBEl = document.getElementById('captured-b');
            capWEl.innerHTML = '';
            capBEl.innerHTML = '';

            const pieceOrder = ['q', 'r', 'b', 'n', 'p'];
            
            // White Captured (by Black)
            capturedPieces.w.sort((a,b) => pieceOrder.indexOf(a) - pieceOrder.indexOf(b)).forEach(p => {
                const icon = document.createElement('span');
                icon.className = 'w-3.5 h-3.5 inline-block';
                icon.innerHTML = PIECE_SVGS[`w-${p}`];
                capWEl.appendChild(icon);
            });

            // Black Captured (by White)
            capturedPieces.b.sort((a,b) => pieceOrder.indexOf(a) - pieceOrder.indexOf(b)).forEach(p => {
                const icon = document.createElement('span');
                icon.className = 'w-3.5 h-3.5 inline-block';
                icon.innerHTML = PIECE_SVGS[`b-${p}`];
                capBEl.appendChild(icon);
            });
        }

        // Render Move History Table
        function renderMoveHistory() {
            const body = document.getElementById('move-log-body');
            body.innerHTML = '';
            document.getElementById('move-count-badge').innerText = `${moveHistory.length} Moves`;

            for (let i = 0; i < moveHistory.length; i += 2) {
                const tr = document.createElement('tr');
                tr.className = 'hover:bg-slate-800/40 transition-colors';

                const numTd = document.createElement('td');
                numTd.className = 'py-1 px-2 text-slate-500 font-bold';
                numTd.innerText = `${Math.floor(i / 2) + 1}.`;

                const wMove = moveHistory[i];
                const wTd = document.createElement('td');
                wTd.className = 'py-1 px-2 text-amber-300 font-semibold';
                wTd.innerText = formatSAN(wMove);

                const bMove = moveHistory[i + 1];
                const bTd = document.createElement('td');
                bTd.className = 'py-1 px-2 text-slate-300 font-semibold';
                bTd.innerText = bMove ? formatSAN(bMove) : '';

                tr.appendChild(numTd);
                tr.appendChild(wTd);
                tr.appendChild(bTd);
                body.appendChild(tr);
            }

            // Auto-scroll move log
            const logContainer = body.parentElement.parentElement;
            logContainer.scrollTop = logContainer.scrollHeight;
        }

        // Format SAN Notation for display
        function formatSAN(record) {
            const { move, board: prevBoard } = record;
            const piece = prevBoard[move.from.r][move.from.c];
            if (!piece) return '';

            if (move.isCastleK) return 'O-O';
            if (move.isCastleQ) return 'O-O-O';

            let sym = piece.type.toUpperCase();
            if (sym === 'P') sym = '';

            const isCapture = prevBoard[move.to.r][move.to.c] !== null || move.isEnPassant;
            const fromFile = String.fromCharCode(97 + move.from.c);
            const capStr = isCapture ? (sym === '' ? fromFile + 'x' : 'x') : '';

            return `${sym}${capStr}${getAlgebraic(move.to.r, move.to.c)}`;
        }

        // Event Listeners Initialization
        document.getElementById('btn-new-game').addEventListener('click', () => {
            sound.init();
            initBoard();
            render();
            updateStatus("New game started. White's turn!");
        });

        document.getElementById('btn-undo').addEventListener('click', () => {
            sound.init();
            undoMove();
        });

        document.getElementById('btn-flip').addEventListener('click', () => {
            isBoardFlipped = !isBoardFlipped;
            render();
        });

        document.getElementById('btn-sound').addEventListener('click', () => {
            sound.muted = !sound.muted;
            const icon = document.getElementById('sound-icon');
            icon.className = sound.muted ? 'fa-solid fa-volume-xmark text-red-400' : 'fa-solid fa-volume-high text-amber-400';
        });

        document.getElementById('select-mode').addEventListener('change', (e) => {
            gameMode = e.target.value;
            initBoard();
            render();
        });

        document.getElementById('select-player-color').addEventListener('change', (e) => {
            playerColor = e.target.value;
            isBoardFlipped = playerColor === 'b';
            initBoard();
            render();
            if (gameMode.startsWith('ai') && currentTurn !== playerColor) {
                setTimeout(makeAIMove, 400);
            }
        });

        document.getElementById('select-theme').addEventListener('change', (e) => {
            document.body.className = `${e.target.value} flex flex-col items-center justify-between p-2 md:p-6 min-h-screen`;
        });

        document.getElementById('modal-btn-restart').addEventListener('click', () => {
            document.getElementById('gameover-modal').classList.add('hidden');
            initBoard();
            render();
        });

        document.getElementById('modal-btn-close').addEventListener('click', () => {
            document.getElementById('gameover-modal').classList.add('hidden');
        });

        // Window Load Bootstrapper
        window.onload = function() {
            initBoard();
            render();
        };
    </script>
</body>
</html>
EOF

echo "Web Server setup complete!"
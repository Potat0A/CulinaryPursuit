<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SpinGame.aspx.cs" Inherits="CulinaryPursuit.SpinGame" MasterPageFile="~/Customer.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <style>
        body {
            background-color: #fff7f2 !important;
            margin: 0;
            padding: 0;
        }

        .spin-page-container {
            padding: 30px 0;
            min-height: 80vh;
        }

        .back-button {
            background: white;
            color: #ff3c00;
            border: 2px solid #ff3c00;
            padding: 8px 18px;
            border-radius: 50px;
            text-decoration: none;
            font-weight: 700;
            font-size: 0.9rem;
            transition: all 0.3s ease;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            display: inline-block;
        }

        .back-button:hover {
            background: #ff3c00;
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(255, 60, 0, 0.3);
        }

        .card-header-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }

        .back-button:hover {
            background: #ff3c00;
            color: white;
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(255, 60, 0, 0.3);
        }

        .pointer {
          position: absolute;
          top: 100px;
          left: 50%;
          transform: translateX(-50%);
          width: 0;
          height: 0;
          border-left: 20px solid transparent;
          border-right: 20px solid transparent;
          border-top: 35px solid #fff;
          z-index: 10;
          filter: drop-shadow(0 4px 8px rgba(0,0,0,0.3));
        }

        .container-card {
            max-width: 480px;
            margin: 0 auto;
            background: white;
            padding: 30px;
            border-radius: 20px;
            box-shadow: 0 8px 25px rgba(0,0,0,0.1);
            position: relative;
        }

        .container-card h2 {
            color: #333;
            font-weight: 800;
            margin-bottom: 20px;
        }

        canvas { display: block; margin: 0 auto; background: transparent; border-radius: 50%; }

        #lblResult { margin-top: 18px; font-size: 1.15rem; min-height: 36px; }

        .btn-spin {
            margin-top: 18px;
            background: linear-gradient(135deg, #ff8c42, #ff5c5c);
            color: white;
            border: none;
            padding: 12px 28px;
            font-size: 1.05rem;
            border-radius: 50px;
            box-shadow: 0 8px 20px rgba(255, 60, 0, 0.3);
            cursor: pointer;
            font-weight: 700;
            transition: all 0.3s ease;
        }

        .btn-spin:hover:not(:disabled) {
            transform: translateY(-2px);
            box-shadow: 0 12px 30px rgba(255, 60, 0, 0.4);
        }

        .btn-spin:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }

        .muted { opacity: 0.86; font-size: 0.9rem; margin-top: 10px; color: #666; }

        .spins-remaining {
            margin-top: 15px;
            font-size: 1.1rem;
            font-weight: 600;
            color: #ff3c00;
        }

        #lblResult {
            color: #333;
            font-weight: 600;
        }

        /* Reward Overlay Styles */
        .reward-overlay {
          position: fixed;
          top: 0;
          left: 0;
          width: 100%;
          height: 100%;
          background: rgba(0, 0, 0, 0.85);
          backdrop-filter: blur(10px);
          z-index: 9999;
          display: none;
          align-items: center;
          justify-content: center;
          animation: fadeIn 0.3s ease;
        }
        .reward-overlay.show { display: flex; }
        @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }

        .reward-card {
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          border-radius: 40px;
          padding: 50px 60px;
          text-align: center;
          position: relative;
          max-width: 500px;
          box-shadow: 0 30px 80px rgba(0, 0, 0, 0.5),
                      0 0 0 20px rgba(255, 255, 255, 0.1);
          animation: popIn 0.5s cubic-bezier(0.68, -0.55, 0.265, 1.55);
          overflow: hidden;
          z-index: 1;
        }
        @keyframes popIn {
          0% { transform: scale(0.3) rotate(-10deg); opacity: 0; }
          100% { transform: scale(1) rotate(0deg); opacity: 1; }
        }

        .sparkles { position: absolute; top: 0; left: 0; width: 100%; height: 100%; pointer-events: none; }
        .sparkle {
          position: absolute;
          width: 8px; height: 8px;
          background: white;
          border-radius: 50%;
          animation: sparkleFloat 2s ease-in-out infinite;
          box-shadow: 0 0 10px rgba(255,255,255,0.8);
        }
        @keyframes sparkleFloat {
          0%,100% { transform: translateY(0) scale(1); opacity: 0; }
          50% { opacity: 1; }
          100% { transform: translateY(-100px) scale(0); }
        }

        .confetti {
          position: absolute;
          width: 10px; height: 10px;
          animation: confettiFall 3s linear infinite;
        }
        @keyframes confettiFall {
          to { transform: translateY(100vh) rotate(360deg); opacity: 0; }
        }

        .rays {
          position: absolute;
          top: 50%; left: 50%;
          width: 400px; height: 400px;
          margin: -200px 0 0 -200px;
          animation: rotate 20s linear infinite;
          opacity: 0.3;
          pointer-events: none;
        }
        @keyframes rotate { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }
        .ray {
          position: absolute;
          top: 50%; left: 50%;
          width: 200px; height: 4px;
          margin: -2px 0 0 0;
          background: linear-gradient(to right, transparent, rgba(255,255,255,0.6), transparent);
          transform-origin: left center;
        }
        .ray:nth-child(1){transform:rotate(0deg);}
        .ray:nth-child(2){transform:rotate(45deg);}
        .ray:nth-child(3){transform:rotate(90deg);}
        .ray:nth-child(4){transform:rotate(135deg);}
        .ray:nth-child(5){transform:rotate(180deg);}
        .ray:nth-child(6){transform:rotate(225deg);}
        .ray:nth-child(7){transform:rotate(270deg);}
        .ray:nth-child(8){transform:rotate(315deg);}

        .trophy-icon {
          font-size: 8rem;
          margin-bottom: 20px;
          animation: bounce 1s ease infinite;
          filter: drop-shadow(0 10px 30px rgba(255,215,0,0.5));
          pointer-events: none;
        }
        @keyframes bounce {
          0%,100% { transform: translateY(0) scale(1); }
          50% { transform: translateY(-20px) scale(1.1); }
        }
        .success-text {
          font-size: 2.5rem;
          font-weight: 700;
          color: #fff;
          margin-bottom: 15px;
          text-shadow: 0 5px 20px rgba(0,0,0,0.3);
          pointer-events: none;
        }
        .reward-amount {
          font-size: 4rem;
          font-weight: 700;
          background: linear-gradient(135deg,#ffd700 0%,#ffed4e 50%,#ffd700 100%);
          -webkit-background-clip: text;
          -webkit-text-fill-color: transparent;
          background-clip: text;
          margin: 20px 0;
          animation: shine 2s linear infinite;
          background-size: 200% auto;
          filter: drop-shadow(0 5px 15px rgba(255,215,0,0.5));
          pointer-events: none;
        }
        @keyframes shine { to { background-position: 200% center; } }
        .reward-subtitle { font-size: 1.3rem; color: rgba(255,255,255,0.9); margin-bottom: 30px; font-weight: 500; pointer-events: none; }
        .close-btn {
          background: linear-gradient(135deg,#f093fb 0%,#f5576c 100%);
          color: white;
          border: none;
          padding: 15px 40px;
          font-size: 1.2rem;
          font-weight: 600;
          border-radius: 50px;
          cursor: pointer;
          box-shadow: 0 10px 30px rgba(245,87,108,0.4);
          transition: all 0.3s ease;
          font-family: 'Fredoka', sans-serif;
          position: relative;
          z-index: 10;
          pointer-events: auto;
        }
        .close-btn:hover { transform: translateY(-3px); box-shadow: 0 15px 40px rgba(245,87,108,0.6); }
        .no-reward-toast {
          position: fixed;
          top: 50%;
          left: 50%;
          transform: translate(-50%, -50%) scale(0.8);
          background: rgba(255, 255, 255, 0.15);
          border: 2px solid rgba(255, 255, 255, 0.3);
          backdrop-filter: blur(10px);
          color: #fff;
          font-family: 'Fredoka', sans-serif;
          font-size: 1.4rem;
          font-weight: 600;
          padding: 20px 40px;
          border-radius: 40px;
          box-shadow: 0 10px 40px rgba(0, 0, 0, 0.4);
          opacity: 0;
          z-index: 99999;
          transition: all 0.4s ease;
        }
        .no-reward-toast.show {
          opacity: 1;
          transform: translate(-50%, -50%) scale(1);
        }

        .spins-remaining {
            margin-top: 15px;
            font-size: 1.1rem;
            font-weight: 600;
            color: #ff3c00;
        }
    </style>

    <div class="container spin-page-container">
        <div class="container-card">
            <div class="card-header-row">
                <h2 style="margin: 0;">Daily Spin</h2>
                <a href="Rewards.aspx" class="back-button">Back to Rewards</a>
            </div>
            <div class="pointer" id="pointer"></div>

        <div style="width:360px;height:360px;margin:0 auto;position:relative;">
            <canvas id="wheelCanvas" width="360" height="360"></canvas>
            <div style="position:absolute;left:50%;top:50%;transform:translate(-50%,-50%);">
                <div style="width:76px;height:76px;border-radius:50%;background:rgba(255,255,255,0.9);display:flex;align-items:center;justify-content:center;color:#333;font-weight:700;">
                    SPIN
                </div>
            </div>
        </div>

        <button type="button" id="btnSpin" class="btn-spin">Spin the Wheel</button>
        <div class="spins-remaining" id="spinsRemaining"></div>
        <div id="lblResult"></div>
        </div>
    </div>

    <div class="reward-overlay" id="rewardOverlay">
        <div class="reward-card">
            <div class="rays">
                <div class="ray"></div><div class="ray"></div><div class="ray"></div><div class="ray"></div>
                <div class="ray"></div><div class="ray"></div><div class="ray"></div><div class="ray"></div>
            </div>
            <div class="sparkles" id="sparklesContainer"></div>
            <div class="trophy-icon"></div>
            <div class="success-text">CONGRATULATIONS!</div>
            <div class="reward-amount" id="rewardAmount">Reward!</div>
            <div class="reward-subtitle">You've won an amazing reward!</div>
            <button id="claimRewardBtn" class="close-btn" onclick="hideReward()">Claim Reward</button>
        </div>
    </div>
    <div id="noRewardToast" class="no-reward-toast">Better luck next time!</div>

    <script>
        // WHEEL_CONFIG is injected by server in Page_Load (SpinGame.aspx.cs)
        (function () {
            if (!window.WHEEL_CONFIG) {
                window.WHEEL_CONFIG = { rewards: ["5 pts", "10 pts", "15 pts", "20 pts", "25 pts", "30 pts", "35 pts", "40 pts"], weights: [15, 15, 15, 15, 15, 10, 10, 5] };
            }

            const canvas = document.getElementById('wheelCanvas');
            const ctx = canvas.getContext('2d');
            const size = canvas.width;
            const cx = size / 2, cy = size / 2;
            const radius = size / 2 - 8;
            const rewards = window.WHEEL_CONFIG.rewards;
            const weights = window.WHEEL_CONFIG.weights;
            const totalWeight = weights.reduce((a, b) => a + b, 0);
            const segments = rewards.length;

            const minAngle = 15;
            let rawAngles = weights.map(w => (w / totalWeight) * 360);
            let adjustedAngles = [...rawAngles];

            let deficit = 0;
            for (let i = 0; i < adjustedAngles.length; i++) {
                if (adjustedAngles[i] < minAngle) {
                    deficit += (minAngle - adjustedAngles[i]);
                    adjustedAngles[i] = minAngle;
                }
            }
            if (deficit > 0) {
                const reducible = adjustedAngles.reduce((sum, a) => sum + (a > minAngle ? (a - minAngle) : 0), 0);
                if (reducible > 0) {
                    for (let i = 0; i < adjustedAngles.length; i++) {
                        if (adjustedAngles[i] > minAngle) {
                            const reduciblePart = adjustedAngles[i] - minAngle;
                            const reduction = (reduciblePart / reducible) * deficit;
                            adjustedAngles[i] -= reduction;
                        }
                    }
                }
            }
            const angles = adjustedAngles;

            const cumulative = [];
            let acc = 0;
            for (let i = 0; i < angles.length; i++) { cumulative.push(acc); acc += angles[i]; }

            const colors = ['#f093fb', '#4facfe', '#43e97b', '#f5576c', '#30cfd0', '#ffd700', '#d39cf5', '#ff8fb4'];

            function drawWheel(rotationDeg = 0) {
                ctx.clearRect(0, 0, size, size);
                ctx.save();
                ctx.translate(cx, cy);
                ctx.rotate(rotationDeg * Math.PI / 180);

                for (let i = 0; i < segments; i++) {
                    const startAngle = (cumulative[i] - 90) * Math.PI / 180;
                    const endAngle = (cumulative[i] + angles[i] - 90) * Math.PI / 180;
                    ctx.beginPath();
                    ctx.moveTo(0, 0);
                    ctx.arc(0, 0, radius, startAngle, endAngle);
                    ctx.closePath();
                    ctx.fillStyle = colors[i % colors.length];
                    ctx.fill();
                    ctx.strokeStyle = 'rgba(255,255,255,0.12)';
                    ctx.lineWidth = 2;
                    ctx.stroke();

                    const mid = (cumulative[i] + angles[i] / 2 - 90) * Math.PI / 180;
                    const textRadius = radius * 0.75;
                    ctx.save();
                    ctx.rotate(mid);
                    ctx.translate(textRadius, 0);
                    ctx.rotate(0);
                    ctx.fillStyle = '#fff';
                    ctx.font = "bold 15px Fredoka, sans-serif";
                    ctx.textAlign = 'center';
                    ctx.textBaseline = 'middle';
                    ctx.shadowColor = 'rgba(0,0,0,0.5)';
                    ctx.shadowBlur = 4;
                    ctx.fillText(rewards[i], 0, 0);
                    ctx.restore();
                }

                ctx.restore();
            }

            drawWheel(0);

            let isSpinning = false;
            const btn = document.getElementById('btnSpin');
            const lbl = document.getElementById('lblResult');
            const spinsRemainingEl = document.getElementById('spinsRemaining');

            function updateSpinsRemaining() {
                if (window.SPINS_REMAINING !== undefined) {
                    const remaining = window.SPINS_REMAINING;
                    if (remaining > 0) {
                        spinsRemainingEl.textContent = `Spins remaining today: ${remaining}`;
                        btn.disabled = false;
                    } else {
                        spinsRemainingEl.textContent = "No spins remaining today. Come back tomorrow!";
                        btn.disabled = true;
                    }
                }
            }
            updateSpinsRemaining();

            async function spin() {
                if (isSpinning) return;
                isSpinning = true;
                btn.disabled = true;
                lbl.textContent = 'Spinning... ';

                try {
                    const resp = await fetch('SpinGame.aspx/SpinWheel', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: '{}'
                    });
                    if (!resp.ok) throw new Error('Network error');
                    const data = await resp.json();
                    const d = data.d;

                    if (!d.success) {
                        lbl.innerHTML = d.message;
                        btn.disabled = false;
                        isSpinning = false;
                        if (d.spinsRemaining !== undefined) {
                            window.SPINS_REMAINING = d.spinsRemaining;
                            updateSpinsRemaining();
                        }
                        return;
                    }

                    const chosenIndex = d.index;
                    const startDeg = cumulative[chosenIndex];
                    const spanDeg = angles[chosenIndex];
                    const centerDeg = startDeg + spanDeg / 2;
                    const fullSpins = 6 + Math.floor(Math.random() * 3);
                    const target = fullSpins * 360 + (360 - centerDeg);

                    const duration = 4200;
                    const start = performance.now();
                    const startRotation = 0;

                    function easeOutCubic(t) { return 1 - Math.pow(1 - t, 3); }

                    function frame(now) {
                        const elapsed = now - start;
                        const t = Math.min(1, elapsed / duration);
                        const eased = easeOutCubic(t);
                        const currentRotation = startRotation + (target - startRotation) * eased;
                        drawWheel(currentRotation % 360);
                        if (t < 1) {
                            requestAnimationFrame(frame);
                        } else {
                            drawWheel(target % 360);

                            const rewardText = d.reward?.trim().toLowerCase();
                            if (rewardText && rewardText !== "nothing " && rewardText !== "try again") {
                                showReward(d.reward);
                            } else {
                                showNoRewardToast(" Better luck next time!");
                                document.getElementById('lblResult').textContent = `Result: ${d.reward}`;
                            }

                            if (d.spinsRemaining !== undefined) {
                                window.SPINS_REMAINING = d.spinsRemaining;
                                updateSpinsRemaining();
                            }

                            btn.disabled = false;
                            isSpinning = false;
                        }
                    }
                    requestAnimationFrame(frame);
                } catch (ex) {
                    console.error(ex);
                    lbl.innerHTML = ' Something went wrong. Try again later.';
                    btn.disabled = false;
                    isSpinning = false;
                }
            }

            btn.addEventListener('click', spin);
            canvas.addEventListener('click', () => {
                if (!isSpinning && !btn.disabled) spin();
            });
            window.addEventListener('resize', () => drawWheel(0));
        })();

        function showReward(rewardText) {
            const overlay = document.getElementById('rewardOverlay');
            const amountEl = document.getElementById('rewardAmount');
            amountEl.textContent = rewardText;
            overlay.classList.add('show');
            createSparkles();
            createConfetti();
        }

        function hideReward() {
            const overlay = document.getElementById('rewardOverlay');
            overlay.classList.remove('show');
            document.getElementById('sparklesContainer').innerHTML = '';
            document.querySelectorAll('.confetti').forEach(c => c.remove());
        }

        function createSparkles() {
            const container = document.getElementById('sparklesContainer');
            container.innerHTML = '';
            for (let i = 0; i < 30; i++) {
                const s = document.createElement('div');
                s.className = 'sparkle';
                s.style.left = Math.random() * 100 + '%';
                s.style.top = Math.random() * 100 + '%';
                s.style.animationDelay = Math.random() * 2 + 's';
                s.style.animationDuration = (1 + Math.random() * 2) + 's';
                container.appendChild(s);
            }
        }

        function createConfetti() {
            const colors = ['#f093fb', '#4facfe', '#43e97b', '#f5576c', '#ffd700', '#ff9bb2'];
            const overlay = document.getElementById('rewardOverlay');
            for (let i = 0; i < 50; i++) {
                const c = document.createElement('div');
                c.className = 'confetti';
                c.style.left = Math.random() * 100 + '%';
                c.style.top = -10 + 'px';
                c.style.background = colors[Math.floor(Math.random() * colors.length)];
                c.style.animationDelay = Math.random() * 0.5 + 's';
                c.style.animationDuration = (2 + Math.random() * 2) + 's';
                overlay.appendChild(c);
            }
        }

        document.getElementById('rewardOverlay').addEventListener('click', e => {
            if (e.target === e.currentTarget) hideReward();
        });
        
        // Explicit button click handler as backup
        const claimBtn = document.getElementById('claimRewardBtn');
        if (claimBtn) {
            claimBtn.addEventListener('click', function(e) {
                e.preventDefault();
                e.stopPropagation();
                hideReward();
            });
        }
        
        document.addEventListener('keydown', e => {
            if (e.key === 'Escape') hideReward();
        });

        function showNoRewardToast(message = " Better luck next time!") {
            const toast = document.getElementById('noRewardToast');
            toast.textContent = message;
            toast.classList.add('show');
            setTimeout(() => {
                toast.classList.remove('show');
            }, 2000);
        }
    </script>
</asp:Content>

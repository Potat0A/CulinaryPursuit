using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.Script.Serialization;
using System.Web.Services;
using System.Web.UI;

namespace CulinaryPursuit
{
    public partial class SpinGame : Page
    {
        // Wheel rewards: points from 5 to 50 (8 sections: 5,10,15,20,25,30,35,40)
        // Max 50 points, whole numbers only
        private static readonly string[] rewards = new[]
        {
            "5 pts", "10 pts", "15 pts", "20 pts", "25 pts", "30 pts", "35 pts", "40 pts"
        };

        // Weights for each reward (higher = more likely)
        private static readonly double[] weights = new[]
        {
            15d, // 5 pts
            15d, // 10 pts
            15d, // 15 pts
            15d, // 20 pts
            15d, // 25 pts
            10d, // 30 pts
            10d, // 35 pts
            5d   // 40 pts (rarest)
        };

        protected void Page_Load(object sender, EventArgs e)
        {
            // Check customer authentication
            if (Session["UserID"] == null || Session["UserType"]?.ToString() != "Customer")
            {
                Response.Redirect("Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (Session["CustomerID"] == null)
            {
                Response.Redirect("Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            // Inject wheel config and spins remaining
            var config = new
            {
                rewards = rewards,
                weights = weights
            };
            var json = new JavaScriptSerializer().Serialize(config);
            string script = $"window.WHEEL_CONFIG = {json};";

            // Get spins remaining for today
            int spinsRemaining = GetSpinsRemainingToday();
            script += $"window.SPINS_REMAINING = {spinsRemaining};";

            ScriptManager.RegisterStartupScript(this, GetType(), "wheelConfig", script, true);
        }

        [WebMethod(EnableSession = true)]
        public static object SpinWheel()
        {
            var ctx = HttpContext.Current;
            
            // Check authentication
            if (ctx.Session["CustomerID"] == null)
            {
                return new { success = false, message = "Please login to spin the wheel." };
            }

            int customerId = Convert.ToInt32(ctx.Session["CustomerID"]);

            // Check daily limit (3 spins per day)
            int spinsToday = GetSpinsCountToday(customerId);
            if (spinsToday >= 3)
            {
                return new { 
                    success = false, 
                    message = "⚠️ You've already spun the wheel 3 times today! Come back tomorrow.",
                    spinsRemaining = 0
                };
            }

            // Weighted random selection
            int chosenIndex = WeightedRandomIndex(weights);
            string chosenReward = rewards[chosenIndex];
            
            // Extract points from reward text (e.g., "25 pts" -> 25)
            int pointsWon = ExtractPoints(chosenReward);

            // Add points to customer account with 1 year expiry
            DateTime expiryDate = DateTime.Now.AddYears(1);
            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                using (SqlTransaction tx = conn.BeginTransaction())
                {
                    try
                    {
                        // Update customer points
                        using (SqlCommand updateCmd = new SqlCommand(@"
UPDATE dbo.Customers
SET RewardPoints = RewardPoints + @Points
WHERE CustomerID = @CustomerID", conn, tx))
                        {
                            updateCmd.Parameters.Add("@Points", SqlDbType.Int).Value = pointsWon;
                            updateCmd.Parameters.Add("@CustomerID", SqlDbType.Int).Value = customerId;
                            updateCmd.ExecuteNonQuery();
                        }

                        // Record spin in session/database (for daily limit tracking)
                        // We'll use a simple approach: store in PointsTransactions with TransactionType = 'SpinWheel'
                        using (SqlCommand insertCmd = new SqlCommand(@"
INSERT INTO dbo.PointsTransactions (CustomerID, TransactionType, Points, Description, ExpiryDate)
VALUES (@CustomerID, 'SpinWheel', @Points, @Description, @ExpiryDate)", conn, tx))
                        {
                            insertCmd.Parameters.Add("@CustomerID", SqlDbType.Int).Value = customerId;
                            insertCmd.Parameters.Add("@Points", SqlDbType.Int).Value = pointsWon;
                            insertCmd.Parameters.Add("@Description", SqlDbType.NVarChar, 500).Value = 
                                $"Won {pointsWon} points from Daily Spin";
                            insertCmd.Parameters.Add("@ExpiryDate", SqlDbType.DateTime).Value = expiryDate;
                            insertCmd.ExecuteNonQuery();
                        }

                        tx.Commit();
                    }
                    catch (Exception ex)
                    {
                        tx.Rollback();
                        return new { success = false, message = $"Error: {ex.Message}" };
                    }
                }
            }

            // Update session points
            if (ctx.Session["CustomerPoints"] != null)
            {
                int currentPoints = Convert.ToInt32(ctx.Session["CustomerPoints"]);
                ctx.Session["CustomerPoints"] = currentPoints + pointsWon;
            }

            int remaining = 3 - (spinsToday + 1);

            return new 
            { 
                success = true, 
                index = chosenIndex, 
                reward = chosenReward,
                spinsRemaining = remaining
            };
        }

        private static int GetSpinsCountToday(int customerId)
        {
            string connStr = ConfigurationManager.ConnectionStrings["CulinaryPursuitDB"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand(@"
SELECT COUNT(*) 
FROM dbo.PointsTransactions 
WHERE CustomerID = @CustomerID 
  AND TransactionType = 'SpinWheel'
  AND CAST(TransactionDate AS DATE) = CAST(GETDATE() AS DATE)", conn))
                {
                    cmd.Parameters.Add("@CustomerID", SqlDbType.Int).Value = customerId;
                    object result = cmd.ExecuteScalar();
                    return result != null ? Convert.ToInt32(result) : 0;
                }
            }
        }

        private int GetSpinsRemainingToday()
        {
            if (Session["CustomerID"] == null) return 0;
            int customerId = Convert.ToInt32(Session["CustomerID"]);
            int spinsToday = GetSpinsCountToday(customerId);
            return Math.Max(0, 3 - spinsToday);
        }

        private static int ExtractPoints(string rewardText)
        {
            // Extract number from "25 pts" format
            string numStr = new string(rewardText.Where(char.IsDigit).ToArray());
            if (int.TryParse(numStr, out int points))
            {
                return points;
            }
            return 0;
        }

        private static int WeightedRandomIndex(double[] arr)
        {
            if (arr == null || arr.Length == 0) return 0;
            double sum = arr.Sum();
            if (sum <= 0)
            {
                var rnd = new Random();
                return rnd.Next(arr.Length);
            }

            var rnd2 = new Random();
            double r = rnd2.NextDouble() * sum;
            double acc = 0;
            for (int i = 0; i < arr.Length; i++)
            {
                acc += arr[i];
                if (r <= acc) return i;
            }
            return arr.Length - 1;
        }
    }
}

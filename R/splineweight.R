#' @import baskexact
#'
#' @export

#' @title Weighting via Monotonic Splines
#'
#' @param design An object of class \code{Basket} created by
#'   \code{setupOneStageBasket} or \code{setupTwoStageBasket}.
#' @param ... Further arguments.
#'
#' @details \code{weights_spline} calculates the weights based on monotonic
#' splines. First, an interpolating spline is defined by the user, identical
#' to the interpolating splines available in \code{\link{splinefun}}.
#' As such, more than two knots have to be specified via the arguments
#' \code{weightknots} and \code{diffknots}, which have to be vectors of
#' matching lengths. Values of corresponding positions within the vectors
#' form the knots used for interpolation.
#' The weight for two baskets i and j is then found by calculating the
#' difference in response rates for binary outcomes and applying the
#' interpolating spline.
#'
#' The \code{clamplim} argument determined specific lower and upper bounds,
#' respectively. If a method for interpolation results in values outside these
#' bounds, they will be set to the given bound. The default is a lower bound
#' of 0 and an upper bound of 1.
#'
#'
#'
#' The function is generally not called by the user but passed to another
#' function such as \code{\link{toer}} and \code{\link{pow}} to specify
#' how the weights are calculated.
#'
#' @return A matrix including the weights of all possible pairwise outcomes.
#' @export
#'
#' @examples
#' design <- setupOneStageBasket(k = 3, p0 = 0.2)
#' toer(design, n = 15, lambda = 0.99, weight_fun = weights_spline)
#'


setGeneric("weights_spline",
           function(design, ...) standardGeneric("weights_spline")
)

#' @describeIn weights_spline Weights for a single-stage basket
#'   design based on monotonic splines.
#'
#' @param design An object of class \code{Basket} created by
#'   \code{setupOneStageBasket} or \code{setupTwoStageBasket}.
#' @param n The sample size per basket.
setMethod("weights_spline", "OneStageBasket",
          function(design,
                   n,
                   diffknots = c(1,0.5,0),
                   weightknots = c(0,0,1),
                   splinemethod = "monoH.FC",
                   clamplim = c(0,1),
                   ...) {

            if (length(diffknots) != length(weightknots))
              stop("Diffknots and weightknots must be vectors of same length!")

            if (length(clamplim) != 2)
              stop("Vector clamplim has to be of lenght 2!")

            if(max(clamplim) == min(clamplim))
              stop("Values of clamplim have to be different!")

            if(min(clamplim < 0 | max(clamplim) > 1))
              stop("Arguments of clamplim out of range! (0 < clamplim < 1)")

            n_sum <- n + 1
            diff_matrix <- matrix(data = NA,
                                  nrow = n_sum,
                                  ncol = n_sum)

            #Create diffmatrix containing all possible response combinations
            for(i in 1:n_sum){
              diff_matrix[,i] <- abs((0:n / n) - ((i-1)/ n))
            }

            #Define interpolating spline
            weight_spline <- splinefun(x=diffknots,
                                       y=weightknots,
                                       method = splinemethod)

            #Apply defined interpolating spline to the diffmatrix
            weight_mat <- apply(X = diff_matrix,
                                MARGIN = 1,
                                FUN = weight_spline)

            #Apply clamping if needed

            upper_clamplim <- max(clamplim)
            lower_clamplim <- min(clamplim)


            weight_mat[weight_mat > upper_clamplim] <- upper_clamplim
            weight_mat[weight_mat < lower_clamplim] <- lower_clamplim


            class(weight_mat) <- "pp"
            weight_mat
          })





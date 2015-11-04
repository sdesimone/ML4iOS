//
//  MultiVote.m
//  ML4iOS
//
//  Created by sergio on 30/10/15.
//
//

#import "MultiVote.h"

#define BINS_LIMIT 32
#define zDistributionDefault 1.96

static NSString* const kNullCategory = @"kNullCategory";

@interface MultiVote ()

@property (nonatomic, strong) NSMutableArray* predictions;

@end

@implementation MultiVote

+ (NSString*)combinationWeightsForMethod:(ML4iOSPredictionMethod)method {
    
    return @[kNullCategory, @"confidence", @"probability", kNullCategory][method];
}

+ (NSArray*)weightLabels {
    return @[@"plurality", @"confidence", @"probability", @"threshold"];
}

+ (NSArray*)weightKeys {
    return @[@[], @[@"confidence"], @[@"distribution", @"count"], @[]];
}

/**
 * MultiVote: combiner class for ensembles voting predictions.
 *
 */
- (instancetype)init {
    
    return [self initWithPredictions:nil];
}


/**
 * MultiVote: combiner class for ensembles voting predictions.
 *
 * @param predictions: Array of model's predictions
 */
- (instancetype)initWithPredictions:(NSArray*)predictions {
    
    if (self = [super init]) {
        
        _predictions = predictions ?: [@[] mutableCopy];
        
        BOOL ordered = YES;
        for (NSDictionary* prediction in _predictions) {
            if (!prediction[@"order"]) {
                ordered = NO;
                break;
            }
        }
        if (!ordered) {
            int count = 0;
            for (NSMutableDictionary* prediction in _predictions) {
                [prediction setObject:@(count++) forKey:@"order"];
            }
        }
    }
    return self;
}

/**
 * Return the next order to be assigned to a prediction
 *
 * Predictions in MultiVote are ordered in arrival sequence when
 * added using the constructor or the append and extend methods.
 * This order is used to break even cases in combination
 * methods for classifications.
 *
 * @return the next order to be assigned to a prediction
 */
- (NSInteger)nextOrder {
    
    if (_predictions && _predictions.count > 0) {
        return [[_predictions.lastObject valueForKey:@"order"] intValue] + 1;
    }
    return 0;
}

/**
 * Given a MultiVote instance, extends its prediction array
 * with another MultiVote's predictions and adds the order information.
 *
 * For instance, predictions_info could be:
 *
 *  [{'prediction': 'Iris-virginica', 'confidence': 0.3},
 *      {'prediction': 'Iris-versicolor', 'confidence': 0.8}]
 *
 *  where the expected prediction keys are: prediction (compulsory),
 *  confidence, distribution and count.
 *
 * @param votes
 */
- (MultiVote*)extendWithMultiVote:(MultiVote*)votes {
    
    NSAssert(votes && votes.predictions.count > 0, @"MultiVote extendWithMultiVote: contract unfulfilled");
    if (votes && votes.predictions.count > 0) {
        
        NSInteger order = [self nextOrder];
        for (NSMutableDictionary* prediction in votes.predictions) {
            [prediction setObject:@(order + 1) forKey:@"order"];
            [_predictions addObject:prediction];
        }
    }
    return self;
}

- (BOOL)areKeysValid:(NSArray*)keys {
    
    for (NSDictionary* prediction in _predictions) {
        for (NSString* key in keys) {
            if (!prediction[key])
                return NO;
        }
    }
    return YES;
}

/**
 * Checks the presence of each of the keys in each of the predictions
 *
 * @param keys {array} keys Array of key strings
 */
- (NSArray*)weigthKeysForMethod:(NSUInteger)method {
 
    NSArray* keys = [NSArray new];
    if (keys.count > 0)
        if (![self areKeysValid:keys])
            return  nil;
    return keys;
}

/**
 * Check if this is a regression model
 *
 * @return {boolean} True if all the predictions are numbers.
 */
- (BOOL)isRegression {
    
    for (NSDictionary* prediction in _predictions) {
        if (![prediction[@"prediction"] isKindOfClass:[NSNumber class]])
             return NO;
    }
    return YES;
}

/**
 * We convert the Array to a dictionary for ease of manipulation
 *
 * @param distribution current distribution as an NSArray
 * @return the distribution as an NSDictionary
 */
- (NSDictionary*)dictionaryFromDistributionArray:(NSArray*)distribution {
    
    NSMutableDictionary* newDistribution = [NSMutableDictionary new];
    for (NSArray* distValue in distribution) {
        [newDistribution setObject:distValue[0] forKey:distValue[1]];
    }
    return newDistribution;
}

/**
 * Convert a dictionary to an array. Dual of dictionaryFromDistributionArray:
 *
 * @param distribution current distribution as an NSDictionary
 * @return the distribution as an NSArray
 */
- (NSArray*)arrayFromDistributionDictionary:(NSDictionary*)distribution {
    
    NSMutableArray* newDistribution = [NSMutableArray new];
    for (id key in [distribution.allKeys sortedArrayUsingSelector:@selector(compare:)]) {
        [newDistribution addObject:@[key, distribution[key]]];
    }
    return newDistribution;
}

/**
 * Adds up a new distribution structure to a map formatted distribution
 *
 * @param dist1
 * @param dist2
 * @return
 */
- (NSMutableDictionary*)mergeDistribution:(NSMutableDictionary*)dist1 andDistribution:(NSDictionary*)dist2 {
    for (id key in dist2.allKeys) {
        if (!dist1[key]) {
            [dist1 setObject:@(0) forKey:key];
        }
        [dist1 setObject:@([dist1[key] intValue] + [dist2[key] intValue])
                 forKey:key];
    }
    return dist1;
}

- (NSArray*)mergeBins:(NSArray*)distribution limit:(NSInteger)limit {
    
    NSInteger length = distribution.count;
    if (limit < 1 || length <= limit || length < 2) {
        return  distribution;
    }
    NSInteger indexToMerge = 2;
    double shortest = HUGE_VAL;
    for (NSUInteger index = 1; index < length; ++index) {
        double distance = [[distribution[index] firstObject] doubleValue] -
        [[distribution[index -1] firstObject] doubleValue];
        
        if (distance < shortest) {
            shortest = distance;
            indexToMerge = index;
        }
    }
    
    NSMutableArray* newDistribution = [NSMutableArray arrayWithArray:
                                     [distribution subarrayWithRange:(NSRange){0, indexToMerge-1}]];
    NSArray* left = distribution[indexToMerge - 1];
    NSArray* right = distribution[indexToMerge];
    NSArray* newBin = @[@0,
                        @(([left[0] doubleValue] * [left[1] doubleValue] +
                        [right[0] doubleValue] * [right[1] doubleValue]) /
                        ([left[1] doubleValue] * [right[1] doubleValue])),
                        @1,
                        @([left[1] longValue] * [right[1] longValue])];
    [newDistribution addObject:newBin];
    
    if (indexToMerge < length -1) {
        [newDistribution addObjectsFromArray:
         [distribution subarrayWithRange:(NSRange){indexToMerge+1, distribution.count - indexToMerge}]];
    }
    
    return [self mergeBins:newDistribution limit:limit];
}

- (NSDictionary*)mergeBinsDictionary:(NSDictionary*)distribution limit:(NSInteger)limit {
    
    NSArray* distributionArray = [self mergeBins:[self arrayFromDistributionDictionary:distribution]
                                           limit:limit];
    return [self dictionaryFromDistributionArray:distributionArray];
}

/**
 * Returns a distribution formed by grouping the distributions of each predicted node.
 */
- (NSDictionary*)mergeDistributionInPrediction:(NSMutableDictionary*)prediction {
    
    NSDictionary* joinedDist = nil;
    NSString* distributionUnit = @"counts";
    for (NSMutableDictionary* p in _predictions) {
        
        NSDictionary* distribution = p[@"distribution"];
        if ([distribution isKindOfClass:[NSArray class]]) {
            distribution = [self dictionaryFromDistributionArray:(id)distribution];
        }
        joinedDist = [self mergeDistribution:[NSMutableDictionary new] andDistribution:distribution];
        if ([distributionUnit isEqualToString:@"counts"] && joinedDist.count > BINS_LIMIT) {
            distributionUnit = @"bins";
        }
        joinedDist = [self mergeBinsDictionary:joinedDist limit:BINS_LIMIT];
    }
    [prediction setObject:[self arrayFromDistributionDictionary:joinedDist] forKey:@"distribution"];
    [prediction setObject:distributionUnit forKey:@"distributionUnit"];
    
    return prediction;
}

/*
 * Shifts and scales predictions errors to [0, top_range]. Then
 * builds e^-[scaled error] and returns the normalization factor to
 * fit them between [0, 1]
 */
- (double)normalizeErrorRange:(double)errorRange topRange:(double)topRange rangeMin:(double)min {
    
    double normalizeFactor = _predictions.count;
    for (NSMutableDictionary* prediction in _predictions) {
        if (errorRange > 0.0) {
            double delta = min - [prediction[@"confidence"] doubleValue];
            [prediction setObject:@(exp(delta / errorRange * topRange)) forKey:@"errorWeight"];
            normalizeFactor += [prediction[@"errorWeight"] doubleValue];
        } else {
            [prediction setObject:@(1.0) forKey:@"errorWeight"];
        }
    }
    return normalizeFactor;
}

/**
 * Normalizes error to a [0, top_range] range and builds probabilities
 *
 * @param topRange {number} The top range of error to which the original error is
 *        normalized.
 * @return {number} The normalization factor as the sum of the normalized
 *         error weights.
 */
- (double)normalizedError:(double)topRange {
    
    double error = 0.0;
    double errorRange = 0.0;
    double maxError = 0.0;
    double minError = HUGE_VAL;
    double normalizeFactor = 0.0;
    for (NSDictionary* prediction in _predictions) {
        NSAssert(prediction[@"confidence"], @"No confidence data to use the selected prediction method");
        error = [prediction[@"confidence"] doubleValue];
        maxError = fmax(error, maxError);
        minError = fmin(error, minError);
    }
    errorRange = maxError - minError;
    normalizeFactor = _predictions.count;
    return [self normalizeErrorRange:errorRange topRange:topRange rangeMin:minError];
}

/**
 * Returns the prediction combining votes using error to compute weight
 *
 * @return {{'prediction': {string|number}, 'confidence': {number}}} The
 *         combined error is an average of the errors in the MultiVote
 *         predictions.
 */
- (NSDictionary*)weightedErrorWithConfidence:(BOOL)confidence
                               addConfidence:(BOOL)addConfidence
                             addDistribution:(BOOL)addDistribution
                                    addCount:(BOOL)addCount
                                   addMedian:(BOOL)addMedian
                                      addMin:(BOOL)addMin
                                      addMax:(BOOL)addMax {
    
    NSAssert([self areKeysValid:@[@"confidence"]],
             @"MultiVote weightedErrorWithConfidence's contract unfulfilled: missing confidence key");
    
    long instances = 0;
    double combinedError = 0.0;
    double topRange = 10.0;
    double result = 0.0;
    double medianResult = 0.0;
    double min = NAN;
    double max = -NAN;
    double normalizationFactor = [self normalizedError:topRange];

    NSMutableDictionary* newPrediction = [NSMutableDictionary new];
    if (normalizationFactor == 0.0) {
        [newPrediction setObject:@(NAN) forKey:@"prediction"];
        [newPrediction setObject:@(0) forKey:@"confidence"];
    }
    for (NSDictionary* prediction in _predictions) {
        
        double medianError = [prediction[@"median"] doubleValue] * [prediction[@"errorWeight"] doubleValue];
        result += medianError;
        if (addMedian) {
            medianResult += medianError;
        }
        if (addCount) {
            instances += [prediction[@"count"] longValue];
        }
        if (addMin && min > [prediction[@"min"] doubleValue]) {
            min = [prediction[@"min"] doubleValue];
        }
        if (addMax && max < [prediction[@"max"] doubleValue]) {
            max = [prediction[@"max"] doubleValue];
        }
        if (confidence || addConfidence) {
            combinedError += [prediction[@"confidence"] doubleValue] * [prediction[@"errorWeight"] doubleValue];
        }
    }
    [newPrediction setObject:@(result/normalizationFactor) forKey:@"prediction"];
    if (addConfidence) {
        [newPrediction setObject:@(combinedError/normalizationFactor) forKey:@"confidence"];
    }
    if (addCount) {
        [newPrediction setObject:@(instances) forKey:@"count"];
    }
    if (addMedian) {
        [newPrediction setObject:@(medianResult/normalizationFactor) forKey:@"median"];
    }
    if (addMin) {
        [newPrediction setObject:@(min) forKey:@"min"];
    }
    if (addMax) {
        [newPrediction setObject:@(max) forKey:@"max"];
    }
    
    return [self mergeDistributionInPrediction:newPrediction];
}

/**
 * Returns the average of a list of numeric values.
 
 * If with_confidence is True, the combined confidence (as the
 * average of confidences of the multivote predictions) is also
 * returned
 *
 */
- (NSDictionary*)averageWithConfidence:(BOOL)confidence
                         addConfidence:(BOOL)addConfidence
                       addDistribution:(BOOL)addDistribution
                              addCount:(BOOL)addCount
                             addMedian:(BOOL)addMedian
                                addMin:(BOOL)addMin
                                addMax:(BOOL)addMax {

    NSInteger total = _predictions.count;
    double result = 0.0;
    double confidenceValue = 0.0;
    double medianResult = 0.0;
    double dMin = INFINITY;
    double dMax = -INFINITY;
    long instances = 0;
    for (NSDictionary* prediction in _predictions) {
        result += [prediction[@"prediction"] doubleValue];
        if (addMedian) {
            medianResult += [prediction[@"median"] doubleValue];
        }
        if (confidence) {
            confidenceValue += [prediction[@"confidence"] doubleValue];
        }
        if (addCount) {
            instances += [prediction[@"count"] doubleValue];
        }
        if (addMin) {
            dMin += [prediction[@"min"] doubleValue];
        }
        if (addMax) {
            dMax += [prediction[@"max"] doubleValue];
        }
    }

    if (total > 0.0) {
        result /= total;
        confidenceValue /= total;
        medianResult /= total;
    } else {
        result = NAN;
        confidenceValue = 0.0;
        medianResult = NAN;
    }

    NSMutableDictionary* output = [@{ @"prediction" : @(result)} mutableCopy];
    if (addConfidence || addDistribution || addCount || addMedian || addMin || addMax) {
        if (addConfidence) {
            [output setObject:@(confidenceValue) forKey:@"confidence"];
        }
        if (addDistribution) {
            [self mergeDistributionInPrediction:output];
        }
        if (addCount) {
            [output setObject:@(instances) forKey:@"count"];
        }
        if (addMedian) {
            [output setObject:@(medianResult) forKey:@"median"];
        }
        if (addMin) {
            [output setObject:@(dMin) forKey:@"min"];
        }
        if (addMax) {
            [output setObject:@(dMax) forKey:@"max"];
        }
    }
    return output;
}

/**
 * Singles out the votes for a chosen category and returns a prediction
 *  for this category if the number of votes reaches at least the given
 *  threshold.
 *
 * @param threshold the number of the minimum positive predictions needed for
 *                    a final positive prediction.
 * @param category the positive category
 * @return MultiVote instance
 */
- (MultiVote*)singleOutCategory:(NSString*)category threshold:(NSInteger)threshold {
    
    NSAssert(threshold > 0 && category.length > 0, @"MultiVote singleOutCategory contract unfulfilled");
    NSAssert(threshold <= _predictions.count, @"MultiVote singleOutCategory: threashold higher than prediction count");
    NSMutableArray* categoryPredictions = [NSMutableArray new];
    NSMutableArray* restOfPredictions = [NSMutableArray new];
    for (NSDictionary* prediction in _predictions) {
        if ([category isEqualToString:prediction[@"prediction"]]) {
            [categoryPredictions addObject:prediction];
        } else {
            [restOfPredictions addObject:prediction];
        }
    }
    if (categoryPredictions.count >= threshold) {
        return [[MultiVote alloc] initWithPredictions:categoryPredictions];
    } else {
        return [[MultiVote alloc] initWithPredictions:restOfPredictions];
    }
}

- (NSDictionary*)weightedConfidence:(id)combinedPrediction weightLabel:(id)weightLabel {
    
    double finalConfidence = 0.0;
    double weight = 1.0;
    double totalWeight = 0.0;
    NSMutableArray* predictionList = [NSMutableArray new];
    
    for (NSDictionary* prediction in _predictions) {
        if ([prediction[@"prediction"] isEqual:combinedPrediction]) {
            [predictionList addObject:prediction];
        }
    }
//    NSMutableArray* predictions = [NSMutableArray new];
//    for (NSDictionary* prediction in predictions) {
//        [predictions addObject:predictionList[]];
//    }
    
    if (weightLabel) {
        for (NSDictionary* prediction in _predictions) {
            NSAssert(prediction[@"confidence"] && prediction[weightLabel],
                     @"MultiVote weightedConfidence: not enough data to use selected method (missing %@)", weightLabel);
        }
    }
    
    for (NSDictionary* prediction in _predictions) {
        if (weightLabel) {
            weight = [prediction[@"confidence"] doubleValue];
        }
        finalConfidence += weight * [prediction[@"confidence"] doubleValue];
        totalWeight += weight;
    }
    
    if (totalWeight > 0) {
        finalConfidence = finalConfidence / totalWeight;
    } else {
        finalConfidence = 0.0;
    }
    
    NSMutableDictionary* result = [NSMutableDictionary new];
    [result setObject:combinedPrediction forKey:@"prediction"];
    [result setObject:@(finalConfidence) forKey:@"confidence"];
    
    return result;
}

/**
 * Builds a distribution based on the predictions of the MultiVote
 *
 * @param weightLabel {string} weightLabel Label of the value in the prediction object
 *        whose sum will be used as count in the distribution
 */
- (NSArray*)combineDistribution:(NSString*)weightLabel {
    
    NSInteger total = 0;
    NSMutableDictionary* distribution = [NSMutableDictionary new];
    
    if (weightLabel.length == 0) {
        weightLabel = [MultiVote weightLabels][ML4iOSPredictionMethodProbability];
    }
    for (NSDictionary* prediction in _predictions) {
        NSAssert(prediction[weightLabel], @"MultiVote combineDistribution contract unfulfilled");
        
        NSString* predictionName = prediction[@"prediction"];
        if (!distribution[predictionName]) {
            [distribution setObject:@(0.0) forKey:predictionName];
        }
        [distribution setObject:@([distribution[predictionName] doubleValue] + [prediction[weightLabel] doubleValue])
                        forKey:predictionName];
        total += [prediction[@"count"] intValue];
    }
    return @[distribution, @(total)];
    
}

/**
 * Wilson score interval computation of the distribution for the prediction
 *
 * @param prediction {object} prediction Value of the prediction for which confidence
 *        is computed
 * @param distribution {array} distribution Distribution-like structure of predictions
 *        and the associated weights (only for categoricals). (e.g.
 *        {'Iris-setosa': 10, 'Iris-versicolor': 5})
 * @param n {integer} n Total number of instances in the distribution. If
 *        absent, the number is computed as the sum of weights in the
 *        provided distribution
 * @param z {float} z Percentile of the standard normal distribution
 */
- (double)wsConfidence:(id)prediction distribution:(NSDictionary*)distribution count:(NSInteger)n z:(double)z {
    
    double z2 = 0.0;
    long n2 = 0.0;
    double wsSqrt = 0.0;
    double p = [distribution[prediction] doubleValue];
    
    z2 = z * z;
    n2 = n * n;
    wsSqrt = sqrt((p * (1 - p) / n) + (z2 / (4 * n2)));
    return (p + (z2 / (2 * n)) - (z * wsSqrt));
}

- (double)wsConfidence:(id)prediction distribution:(NSDictionary*)distribution count:(NSInteger)n {
    return [self wsConfidence:prediction distribution:distribution count:n z:zDistributionDefault];
}

- (double)wsConfidence:(id)prediction distribution:(NSDictionary*)distribution {
    
    double p = [distribution[prediction] doubleValue];
    NSAssert(p >= 0, @"Distribution weight must be a positive value");

    double norm = 0.0;
    for (NSString* key in distribution.allKeys) {
        norm += [distribution[key] doubleValue];
    }
    NSAssert(norm != 0.0, @"Invalid distribution norm");
    if (norm != 1.0) {
        p = p / norm;
    }

    return [self wsConfidence:prediction distribution:distribution count:floor(norm) z:zDistributionDefault];
}

- (NSDictionary*)combineCategorical:(NSString*)weightLabel confidence:(BOOL)confidence {
    
    double weight = 1.0;
    id category;
    NSMutableDictionary* mode = [NSMutableDictionary new];
    NSMutableArray* tuples = [NSMutableArray new];
    
    for (NSDictionary* prediction in _predictions) {
        if (!weightLabel) {
            NSAssert([[MultiVote weightLabels] indexOfObject:weightLabel] != NSNotFound,
                     @"MultiVote combineCategorical: wrong weightLabel");
            NSAssert(prediction[weightLabel],
                     @"MultiVote combineCategorical: Not enough data to use the selected prediction method.");
        } else {
            weight = [prediction[weightLabel] doubleValue];
        }
        category = prediction[@"prediction"];
        
        NSMutableDictionary* categoryHash = [NSMutableDictionary new];
        if (mode[category]) {
            [categoryHash setObject:@([mode[category][@"count"] doubleValue] + weight) forKey:@"count"];
            [categoryHash setObject:mode[category][@"order"] forKey:@"order"];
        } else {
            [categoryHash setObject:@(weight) forKey:@"count"];
            [categoryHash setObject:prediction[@"order"] forKey:@"order"];
        }
        [mode setObject:categoryHash forKey:category];
    }
    for (id key in mode.allKeys) {
        if (mode[key]) {
            NSArray* tuple = @[key, mode[key]];
            [tuples addObject:tuple];
        }
    }
    NSArray* tuple = [tuples sortedArrayUsingComparator:^NSComparisonResult(NSDictionary*  _Nonnull obj1, NSDictionary*  _Nonnull obj2) {
        double w1 = [obj1[@"count"] doubleValue];
        double w2 = [obj2[@"count"] doubleValue];
        int order1 = [obj1[@"order"] intValue];
        int order2 = [obj2[@"order"] intValue];
        return w1 > w2 ? -1 : (w1 < w2 ? 1 : order1 < order2 ? -1 : 1);
    }].firstObject;
    id predictionName = tuple.firstObject;
    
    NSMutableDictionary* result = [NSMutableDictionary new];
    [result setObject:predictionName forKey:@"prediction"];
    
    if (confidence) {
        if ([_predictions.firstObject valueForKey:@"confidence"]) {
            return [self weightedConfidence:predictionName weightLabel:weightLabel];
        }
        
        NSArray* distributionInfo = [self combineDistribution:weightLabel];
        NSInteger count = [distributionInfo[1] intValue];
        NSDictionary* distribution = distributionInfo[0];
        double combinedConfidence = [self wsConfidence:predictionName distribution:distribution count:count];
        [result setObject:@(combinedConfidence) forKey:@"confidence"];
    }
    return result;
}

/**
 * Reduces a number of predictions voting for classification and averaging
 * predictions for regression.
 *
 * @param method {0|1|2|3} method Code associated to the voting method (plurality,
 *        confidence weighted or probability weighted or threshold).
 * @param withConfidence if withConfidence is true, the combined confidence
 *                       (as a weighted of the prediction average of the confidences
 *                       of votes for the combined prediction) will also be given.
 * @return {{"prediction": prediction, "confidence": combinedConfidence}}
 */
- (NSDictionary*)combineWithMethod:(ML4iOSPredictionMethod)method
                        confidence:(BOOL)confidence
                     addConfidence:(BOOL)addConfidence
                   addDistribution:(BOOL)addDistribution
                          addCount:(BOOL)addCount
                         addMedian:(BOOL)addMedian
                            addMin:(BOOL)addMin
                            addMax:(BOOL)addMax
                           options:(NSDictionary*)options {
    
    NSAssert(_predictions && _predictions.count > 0,
             @"MultiVote combineWithMethod's contract unfulfilled: missing predictions");
    NSAssert([self weigthKeysForMethod:method],
             @"MultiVote combineWithMethod's contract unfulfilled: missing keys");
    
    if ([self isRegression]) {
        
        for (NSMutableDictionary* prediction in _predictions) {
            [prediction setObject:prediction[@"confidence"]?:@(0) forKey:@"confidence"];
        }
        if (method == ML4iOSPredictionMethodConfidence) {
            return [self weightedErrorWithConfidence:confidence
                                       addConfidence:addConfidence
                                     addDistribution:addDistribution
                                            addCount:addCount
                                           addMedian:addMedian
                                              addMin:addMin
                                              addMax:addMax];
        }
        return [self averageWithConfidence:confidence
                             addConfidence:addConfidence
                           addDistribution:addDistribution
                                  addCount:addCount
                                 addMedian:addMedian
                                    addMin:addMin
                                    addMax:addMax];
    }
    
    MultiVote* votes = nil;
    if (method == ML4iOSPredictionMethodThreshold) {
        NSInteger threshold = [options[@"threshold"] intValue];
        NSString* category = options[@"category"];
        votes = [self singleOutCategory:category threshold:threshold];
    } else if (method == ML4iOSPredictionMethodProbability) {
//        votes = [MultiVote multiVoteWithProbabilityWeight:[self probabilityWeight]];
    } else {
        votes = self;
    }
    
    return [votes combineCategorical:[MultiVote combinationWeightsForMethod:method]
                          confidence:confidence];
}

/**
 * Adds a new prediction into a list of predictions
 *
 * prediction_info should contain at least:
 *      - prediction: whose value is the predicted category or value
 *
 * for instance:
 *      {'prediction': 'Iris-virginica'}
 *
 * it may also contain the keys:
 *      - confidence: whose value is the confidence/error of the prediction
 *      - distribution: a list of [category/value, instances] pairs
 *                      describing the distribution at the prediction node
 *      - count: the total number of instances of the training set in the
 *                  node
 *
 * @param predictionInfo the prediction to be appended
 * @return the this instance
 */
- (void)append:(NSMutableDictionary*)predictionInfo {
    
    NSAssert(predictionInfo.allKeys.count > 0 && predictionInfo[@"prediction"],
             @"Failed to append prediction");
 
    NSInteger order = [self nextOrder];
    [predictionInfo setObject:@(order) forKey:@"order"];
    [_predictions addObject:predictionInfo];
}

- (void)addMedian {
    
    for (NSMutableDictionary* prediction in _predictions) {
        [prediction setObject:prediction[@"median"] forKey:@"prediction"];
    }
}

@end


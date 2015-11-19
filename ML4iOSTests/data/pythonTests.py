#!/usr/bin/env python

from bigml.api import BigML
from bigml.model import Model
from bigml.ensemble import Ensemble
from bigml.anomaly import Anomaly

api = BigML(dev_mode=True)
model = api.get_model('model/563a1c7a3cd25747430023ce')
prediction = api.create_prediction(model, {'petal length': 4.07, 'sepal width': 3.15, 'petal width': 1.51})

local_model = Model('model/56430eb8636e1c79b0001f90', api=api)
prediction = local_model.predict({'petal length': 0.96, 'sepal width': 4.1, 'petal width': 2.52}, 2, add_confidence=True, multiple=3)

local_model = Ensemble('ensemble/564a02d5636e1c79b5006e13', api=api)
local_model = Ensemble('ensemble/564a081bc6c19b6cf3011c60', api=api)
prediction = local_model.predict({'petal length': 0.95, 'sepal width': 3.9, 'petal width': 1.51, 'sepal length': 7.0}, method=2, add_confidence=True)

local_ensemble = Ensemble('ensemble/564623d4636e1c79b00051f7', api=api)
prediction = local_ensemble.predict({'Price' : 5.8, 'Grape' : 'Pinot Grigio', 'Country' : 'Italy', 'Rating' : 92}, True)

local_anomaly = Anomaly('anomaly/564c5a76636e1c3d52000007', api=api)
prediction = local_anomaly.anomaly_score({'petal length': 4.07, 'sepal width': 3.15, 'petal width': 1.51, 'sepal length': 6.02, 'species': 'Iris-setosa'}, True)
prediction = local_anomaly.anomaly_score({'petal length': 0.96, 'sepal width': 4.1, 'petal width': 2.51, 'sepal length': 6.02, 'species': 'Iris-setosa'}, True)
prediction = local_anomaly.anomaly_score({'petal length': 0.96, 'sepal width': 4.1, 'petal width': 2.51}, True)

api.pprint(prediction)

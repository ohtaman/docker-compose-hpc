import os

import optuna
import tensorflow as tf


def objective(trial):
    tf.keras.backend.clear_session()
    
    batch_size = trial.suggest_int('batch_size', 16, 256)
    n_layers = trial.suggest_int('n_layers', 1, 5)
    n_units = trial.suggest_int('n_units', 16, 128)
    
    (train_x, train_y), (test_x, test_y) = tf.keras.datasets.mnist.load_data()
    train_x = train_x/255.
    test_x = test_x/255.
    
    model = tf.keras.models.Sequential()
    model.add(tf.keras.layers.Flatten(input_shape=(28, 28)))
    for _ in range(n_layers):
        model.add(tf.keras.layers.Dense(n_units, activation='relu'))
    model.add(tf.keras.layers.Dense(10, activation='softmax'))
    
    model.compile(
        optimizer='adam',
        loss='sparse_categorical_crossentropy',
        metrics=['accuracy']
    )
    history = model.fit(train_x, train_y, validation_data=(test_x, test_y), epochs=5, batch_size=batch_size)

    return history.history['val_accuracy'][-1]
    

def main():
    # Optuna で分散並列最適化を行うには、storage を指定する
    # https://www.slideshare.net/pfi/20201023-optunalectureatnagoyauni-238946529
    study = optuna.create_study(
        direction='maximize',
        storage='sqlite:///db.sqlite3',
    )
    study.optimize(objective, n_trials=5)

    print(f'best value: {study.best_value}')
    print(f'best parameters: {study.best_params}')

if __name__ == '__main__':
    main()
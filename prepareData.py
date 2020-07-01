import turicreate as tc

data = tc.image_analysis.load_images("trainingData")

print("loaded counts",len(data))

data["label"] = data["path"].apply(lambda path: "cat" if "cat" in path else "dog")

data.save("cats-dogs.sframe")

data.explore()
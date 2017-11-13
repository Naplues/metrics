library(moments)  #计算峰度和偏度
library(mlr)      #机器学习库
library(scmamp)   #作cd图和Algorithm图
library(plotrix)  #作heatmap图

############################ 方法定义 ####################################
#a.描述性统计信息
calc_statis <- function(data) {
	final.data <- NULL
	for ( i in 1:length(metrics) ) {
		#summary(data[,i])
		max <- max(data[,i])
		min <- min(data[,i])
		mean <- mean(data[,i])
		median <- median(data[,i])
		Q1 <- quantile(data[,i], probs = 0.25)
		Q3 <- quantile(data[,i], probs = 0.75)
		skew <- skewness(data[,i])      #偏度
		kurt <- kurtosis(data[,i]) - 3  #峰度moment包需要-3
		#加入数据帧
		new.data <- data.frame(metrics[i], min, unname(Q1), median, unname(Q3), max, mean, skew, kurt)
		final.data <- rbind(final.data, new.data)
	}
	names(final.data) <- c('name', 'min', 'Q1', 'median', 'Q3', 'max', 'mean', 'skewness', 'kurtosis')
	write.csv(final.data,"statis.csv")
}

#b.计算相关系数和显著性水平（Spearman和Pearson）
calc_cor <- function(data) {
	final.data <- NULL
	n <- length(metrics)
	final.r.spearman <- NULL;final.T.spearman <- NULL;final.r.pearson <- NULL;final.T.pearson <- NULL
	
	for( i in 1:n ) {
		#Spearman
		r.spearman <- cor(data[,i], bugs, method = "spearman")
		T.spearman <- r.spearman*( sqrt(n-2)/sqrt(1- r.spearman ^2 ) )
		final.r.spearman <- c(final.r.spearman, r.spearman)
		final.T.spearman <- c(final.T.spearman, T.spearman)		
		#Pearson
		r.pearson <- cor(data[,i], bugs, method = "pearson")
		T.pearson <- r.pearson*(sqrt(n-2))/sqrt(1- r.pearson ^2)  #显著性水平
		final.r.pearson <- c(final.r.pearson, r.pearson)
		final.T.pearson <- c(final.T.pearson, T.pearson)
		#加入数据帧
		new.data <- data.frame(metrics[i], r.spearman, T.spearman, r.pearson, T.pearson)
		final.data <- rbind(final.data, new.data)
	}
	names(final.data) <- c('name', 'r.spearman', 'T.spearman', 'r.pearson', 'T.pearson')
	write.csv(final.data,"cor.csv")  
}

#c.d.用机器学习的方法建立模型并评估
make_and_evaluate_model <- function() {
	a <- NULL
	for(x in bugs) {
		if(x > 0)
			a <-c(a, as.integer(1))
		else
			a <-c(a, as.integer(0))
	}
	train_data <- features
	train_data$bugs <- a

	## 1) 定义分类任务
	task = makeClassifTask(data = train_data, target = "bugs")
	learners <- c( 
		"classif.naiveBayes",     #朴素贝叶斯分类器
		"classif.svm",            #支持向量机
		"classif.gbm",            #梯度推进机
		"classif.lda",            #线性判别分析
		"classif.mlp",            #多层感知器
		"classif.randomForest",   #随机森林
		"classif.rpart",          #决策树
		"classif.glmnet",         #GLM with Lasso or Elasticnet Regularization
		"classif.nnet",           #神经网络
		"classif.multinom"        #多元回归
		)
	n = nrow(train_data)
	final.per = NULL  #
	#进行十种方法学习#10次10折交叉验证
	for( x in 1:10 ) {
		#数据集划分,10折交叉验证
		folds <- caret::createFolds(y = train_data$bugs, k = 10)
		#进行一次10折交叉验证	
		for(i in 1:10 ) {
			test.set = folds[[i]]
			train.set = setdiff(1:n, test.set)
			for( l in learners ) {
				## 2) 定义学习器(线性判别分析)
				learner = makeLearner(l, predict.type = "prob")
				final.mmce = 0  #误差
				final.acc = 0   #精度
				model = train(learner, task, subset = train.set) ## 3) 拟合模型
				pred = predict(model, task = task, subset = test.set) ## 4) 预测模型
				res = performance(pred, measures = list(mmce, acc, auc ))  ## 5) 评估性能 平均误分类误差和精度
				m_auc = unname(res['auc'])
				m_ce = (m_auc - 0.5) / 0.5
				#加入数据帧
				new.per <- data.frame(l, unname(res['mmce']), unname(res['acc']), unname(res['auc']), m_ce)
				final.per <- rbind(final.per, new.per)
			}
		}
	}
	names(final.per) <- c('learn method', 'mmce', 'acc', 'auc', 'ce')
	write.csv(final.per, "performance.csv")
}

#获取统计数据
get_data <- function() {
	data <- read.csv(file = "performance.csv")
	mauc <- array(data$auc, c(100, 10))
	m_auc <- NULL
	for(i in 1:100) {
		nf <- data.frame(mauc[i,1], mauc[i,2], mauc[i,3], mauc[i,4], mauc[i,5],
					mauc[i,6], mauc[i,7], mauc[i,8], mauc[i,9], mauc[i,10])
		m_auc <- rbind(m_auc, nf)
	}
	name <- c('naiveBayes', 'svm', 'gbm', 'lda', 'mlp',
		'randomForest', 'rpart', 'glmnet', 'nnet', 'mulitnom')
	names(m_auc) <- name
	m_auc
}

#e.作CD图比较统计差别
graph_cd <- function(data) {
	png(file = "AUC-CD.png")
	plotCD(results.matrix = data, alpha = 0.05)
	dev.off()
}

#f.画算法图比较统计差别
graph_algorithm <- function(data) {
	data <- filterData(data, remove.cols=1)  #过滤数据
	res <- postHocTest(data, test = "friedman", use.rank=TRUE, correct="bergmann")
	drawAlgorithmGraph(res$corrected.pval, res$summary)
}

#g.作heatmap图展示模型在测试集上的结果
graph_heatmap <- function(data) {
	library(plotrix)
	m <- as.matrix(data)
	png(file = "heatmap.png")
	heatmap(m) #m 矩阵
	dev.off()
}

############################ 主程序开始 ####################################
#设置当前目录
setwd("C:/Users/naplues/Desktop/metrics/exercise/hw3")
data <- read.csv(file = "xalan-2.4.csv")

features <- data[,4:9] # 取出指定数据  4-9列
bugs <- data[,24]      # 24列
metrics <- c('wmc', 'dit', 'noc', 'cbo', 'rfc', 'lcom') #度量指标

#任务步骤
calc_statis(features)                 #a.描述性统计信息,输出结果"statis.csv"
calc_cor(features)                    #b.计算相关系数及显著性统计,输出结果"cor.csv"

make_and_evaluate_model()             #c.构建模型并评估

graph_data <- get_data()                   #获取作图数据
graph_cd(graph_data)                       #e.作CD图
graph_algorithm(graph_data)                #f.作Algorithm图
graph_heatmap(graph_data)                  #g.作heatmap图
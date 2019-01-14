package com.drawflower.rndrawcanvas;

import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.PointF;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.Rect;
import android.graphics.RectF;

import java.util.ArrayList;
import java.util.Random;

public class DrawData {
    public final ArrayList<PointF> points = new ArrayList<PointF>();
    public final ArrayList<PointF> points1 = new ArrayList<PointF>();
    public final ArrayList<PointF> points2 = new ArrayList<PointF>();
    public final ArrayList<PointF> points3 = new ArrayList<PointF>();
    public final ArrayList<PointF> points4 = new ArrayList<PointF>();
    public final int id, strokeColor;
    public final float strokeWidth;
    public final boolean isTranslucent;

    private Paint mPaint;
    private Path mPath;
    private Path mPath1, mPath2, mPath3, mPath4;
    private RectF mDirty = null;

    public static PointF midPoint(PointF p1, PointF p2) {
        return new PointF((p1.x + p2.x) * 0.5f, (p1.y + p2.y) * 0.5f);
    }

    public DrawData(int id, int strokeColor, float strokeWidth) {
        this.id = id;
        this.strokeColor = strokeColor;
        this.strokeWidth = strokeWidth;
        this.isTranslucent = ((strokeColor >> 24) & 0xff) != 255 && strokeColor != Color.TRANSPARENT;
        mPath = this.isTranslucent ? new Path() : null;
        mPath1 = this.isTranslucent ? new Path() : null;
        mPath2 = this.isTranslucent ? new Path() : null;
        mPath3 = this.isTranslucent ? new Path() : null;
        mPath4 = this.isTranslucent ? new Path() : null;
    }

    public DrawData(int id, int strokeColor, float strokeWidth, ArrayList<PointF> points) {
        this.id = id;
        this.strokeColor = strokeColor;
        this.strokeWidth = strokeWidth;
        this.points.addAll(points);
        this.isTranslucent = ((strokeColor >> 24) & 0xff) != 255 && strokeColor != Color.TRANSPARENT;
        mPath = this.isTranslucent ? evaluatePath() : null;
        mPath1 = this.isTranslucent ? evaluatePath1() : null;
        mPath2 = this.isTranslucent ? evaluatePath2() : null;
        mPath3 = this.isTranslucent ? evaluatePath3() : null;
        mPath4 = this.isTranslucent ? evaluatePath4() : null;
    }

    private float number() {
        int min = 1;
        int max = (int)this.strokeWidth / 2;
        Random random = new Random();
        return random.nextInt((max + 1) - min) + min;
    }

    public Rect addPoint(PointF p) {
        points.add(p);

        RectF updateRect;

        PointF p1 = new PointF(p.x - this.number(), p.y - this.number());
        PointF p2 = new PointF(p.x + this.number(), p.y - this.number());
        PointF p3 = new PointF(p.x + this.number(), p.y + this.number());
        PointF p4 = new PointF(p.x - this.number(), p.y + this.number());

        points1.add(p1);
        points2.add(p1);
        points3.add(p1);
        points4.add(p1);

        int pointsCount = points.size();

        if (this.isTranslucent) {
            if (pointsCount >= 3) {
                PointF a1 = this.points1.get(pointsCount - 2);
                mPath1.moveTo(a1.x, a1.y);
                mPath1.lineTo(p1.x, p1.y);
                PointF a2 = this.points2.get(pointsCount - 2);
                mPath2.moveTo(a2.x, a2.y);
                mPath2.lineTo(p2.x, p2.y);

                PointF a = this.points.get(pointsCount - 2);
                mPath.moveTo(a.x, a.y);
                mPath.lineTo(p.x, p.y);

                PointF a3 = this.points3.get(pointsCount - 2);
                mPath3.moveTo(a3.x, a3.y);
                mPath3.lineTo(p3.x, p3.y);
                PointF a4 = this.points4.get(pointsCount - 2);
                mPath4.moveTo(a4.x, a4.y);
                mPath4.lineTo(p4.x, p4.y);
            } else if (pointsCount >= 2) {
                PointF a1 = this.points1.get(0);
                mPath1.moveTo(a1.x, a1.y);
                mPath1.lineTo(p1.x, p1.y);
                PointF a2 = this.points2.get(0);
                mPath2.moveTo(a2.x, a2.y);
                mPath2.lineTo(p2.x, p2.y);

                PointF a = this.points.get(0);
                mPath.moveTo(a.x, a.y);
                mPath.lineTo(p.x, p.y);

                PointF a3 = this.points3.get(0);
                mPath3.moveTo(a3.x, a3.y);
                mPath3.lineTo(p3.x, p3.y);
                PointF a4 = this.points4.get(0);
                mPath4.moveTo(a4.x, a4.y);
                mPath4.lineTo(p4.x, p4.y);
            } else {
                mPath1.moveTo(p1.x, p1.y);
                mPath1.lineTo(p1.x, p1.y);
                mPath2.moveTo(p2.x, p2.y);
                mPath2.lineTo(p2.x, p2.y);

                mPath.moveTo(p.x, p.y);
                mPath.lineTo(p.x, p.y);

                mPath3.moveTo(p3.x, p3.y);
                mPath3.lineTo(p3.x, p3.y);
                mPath4.moveTo(p4.x, p4.y);
                mPath4.lineTo(p4.x, p4.y);
            }

            float x = p.x, y = p.y;
            if (mDirty == null) {
                mDirty = new RectF(x, y, x + 1, y + 1);
                updateRect = new RectF(x - this.strokeWidth, y - this.strokeWidth, 
                    x + this.strokeWidth, y + this.strokeWidth);
            } else {
                mDirty.union(x, y);
                updateRect = new RectF(
                                    mDirty.left - this.strokeWidth, mDirty.top - this.strokeWidth,
                                    mDirty.right + this.strokeWidth, mDirty.bottom + this.strokeWidth
                                    );
            }
        } else {
            if (pointsCount >= 3) {
                PointF a = points.get(pointsCount - 3);
                PointF b = points.get(pointsCount - 2);
                PointF c = p;
                PointF prevMid = midPoint(a, b);
                PointF currentMid = midPoint(b, c);

                updateRect = new RectF(prevMid.x, prevMid.y, prevMid.x, prevMid.y);
                updateRect.union(b.x, b.y);
                updateRect.union(currentMid.x, currentMid.y);
            } else if (pointsCount >= 2) {
                PointF a = points.get(pointsCount - 2);
                PointF b = p;
                PointF mid = midPoint(a, b);

                updateRect = new RectF(a.x, a.y, a.x, a.y);
                updateRect.union(mid.x, mid.y);
            } else {
                updateRect = new RectF(p.x, p.y, p.x, p.y);
            }

            updateRect.inset(-strokeWidth * 2, -strokeWidth * 2);

        }
        Rect integralRect = new Rect();
        updateRect.roundOut(integralRect);
        
        return integralRect;
    }

    public void drawLastPoint(Canvas canvas) {
        int pointsCount = points.size();
        if (pointsCount < 1) {
            return;
        }

        draw(canvas, pointsCount - 1);
    }

    public void draw(Canvas canvas) {
        if (this.isTranslucent) {
            canvas.drawPath(mPath, getPaint());
        } else {
            int pointsCount = points.size();
            for (int i = 0; i < pointsCount; i++) {
                draw(canvas, i);
            }
        }
    }

    private Paint getPaint() {
        if (mPaint == null) {
            boolean isErase = strokeColor == Color.TRANSPARENT;

            mPaint = new Paint();
            mPaint.setColor(strokeColor);
            mPaint.setStrokeWidth(strokeWidth);
            mPaint.setStyle(Paint.Style.STROKE);
            mPaint.setStrokeCap(Paint.Cap.ROUND);
            mPaint.setStrokeJoin(Paint.Join.ROUND);
            mPaint.setAntiAlias(false);
            mPaint.setXfermode(new PorterDuffXfermode(isErase ? PorterDuff.Mode.CLEAR : PorterDuff.Mode.SRC_OVER));
        }
        return mPaint;
    }

    private void draw(Canvas canvas, int pointIndex) {
        int pointsCount = points.size();
        if (pointIndex >= pointsCount) {
            return;
        }

        if (pointsCount >= 3 && pointIndex >= 2) {
            PointF a1 = points1.get(pointIndex - 1);
            PointF b1 = points1.get(pointIndex);
            canvas.drawLine(a1.x, a1.y, b1.x, b1.y, getPaint());
            PointF a2 = points2.get(pointIndex - 1);
            PointF b2 = points2.get(pointIndex);
            canvas.drawLine(a2.x, a2.y, b2.x, b2.y, getPaint());

            PointF a = points.get(pointIndex - 1);
            PointF b = points.get(pointIndex);
            canvas.drawLine(a.x, a.y, b.x, b.y, getPaint());

            PointF a3 = points3.get(pointIndex - 1);
            PointF b3 = points3.get(pointIndex);
            canvas.drawLine(a3.x, a3.y, b3.x, b3.y, getPaint());
            PointF a4 = points4.get(pointIndex - 1);
            PointF b4 = points4.get(pointIndex);
            canvas.drawLine(a4.x, a4.y, b4.x, b4.y, getPaint());
        } else if (pointsCount >= 2 && pointIndex >= 1) {
            PointF a1 = points1.get(pointIndex - 1);
            PointF b1 = points1.get(pointIndex);
            canvas.drawLine(a1.x, a1.y, b1.x, b1.y, getPaint());
            PointF a2 = points2.get(pointIndex - 1);
            PointF b2 = points2.get(pointIndex);
            canvas.drawLine(a2.x, a2.y, b2.x, b2.y, getPaint());

            PointF a = points.get(pointIndex - 1);
            PointF b = points.get(pointIndex);
            canvas.drawLine(a.x, a.y, b.x, b.y, getPaint());

            PointF a3 = points3.get(pointIndex - 1);
            PointF b3 = points3.get(pointIndex);
            canvas.drawLine(a3.x, a3.y, b3.x, b3.y, getPaint());
            PointF a4 = points4.get(pointIndex - 1);
            PointF b4 = points4.get(pointIndex);
            canvas.drawLine(a4.x, a4.y, b4.x, b4.y, getPaint());
        } else if (pointsCount >= 1) {
            PointF a1 = points1.get(pointIndex);
            canvas.drawPoint(a1.x, a1.y, getPaint());
            PointF a2 = points2.get(pointIndex);
            canvas.drawPoint(a2.x, a2.y, getPaint());

            PointF a = points.get(pointIndex);
            canvas.drawPoint(a.x, a.y, getPaint());

            PointF a3 = points3.get(pointIndex);
            canvas.drawPoint(a3.x, a3.y, getPaint());
            PointF a4 = points4.get(pointIndex);
            canvas.drawPoint(a4.x, a4.y, getPaint());
        }
    }

    private Path evaluatePath() {
        int pointsCount = points.size();
        Path path = new Path();

        for(int pointIndex=0; pointIndex<pointsCount; pointIndex++) {
            if (pointsCount >= 3 && pointIndex >= 2) {
                PointF a = points.get(pointIndex - 1);
                PointF b = points.get(pointIndex);
                path.moveTo(a.x, a.y);
                path.lineTo(b.x, b.y);
            } else if (pointsCount >= 2 && pointIndex >= 1) {
                PointF a = points.get(pointIndex - 1);
                PointF b = points.get(pointIndex);
                path.moveTo(a.x, a.y);
                path.lineTo(b.x, b.y);
            } else if (pointsCount >= 1) {
                PointF a = points.get(pointIndex);
                path.moveTo(a.x, a.y);
                path.lineTo(a.x, a.y);
            }
        }
        return path;
    }

    private Path evaluatePath1() {
        int pointsCount = points1.size();
        Path path = new Path();

        for(int pointIndex=0; pointIndex<pointsCount; pointIndex++) {
            if (pointsCount >= 3 && pointIndex >= 2) {
                PointF a = points1.get(pointIndex - 1);
                PointF b = points1.get(pointIndex);
                path.moveTo(a.x, a.y);
                path.lineTo(b.x, b.y);
            } else if (pointsCount >= 2 && pointIndex >= 1) {
                PointF a = points1.get(pointIndex - 1);
                PointF b = points1.get(pointIndex);
                path.moveTo(a.x, a.y);
                path.lineTo(b.x, b.y);
            } else if (pointsCount >= 1) {
                PointF a = points1.get(pointIndex);
                path.moveTo(a.x, a.y);
                path.lineTo(a.x, a.y);
            }
        }
        return path;
    }

    private Path evaluatePath2() {
        int pointsCount = points2.size();
        Path path = new Path();

        for(int pointIndex=0; pointIndex<pointsCount; pointIndex++) {
            if (pointsCount >= 3 && pointIndex >= 2) {
                PointF a = points2.get(pointIndex - 1);
                PointF b = points2.get(pointIndex);
                path.moveTo(a.x, a.y);
                path.lineTo(b.x, b.y);
            } else if (pointsCount >= 2 && pointIndex >= 1) {
                PointF a = points2.get(pointIndex - 1);
                PointF b = points2.get(pointIndex);
                path.moveTo(a.x, a.y);
                path.lineTo(b.x, b.y);
            } else if (pointsCount >= 1) {
                PointF a = points2.get(pointIndex);
                path.moveTo(a.x, a.y);
                path.lineTo(a.x, a.y);
            }
        }
        return path;
    }

    private Path evaluatePath3() {
        int pointsCount = points3.size();
        Path path = new Path();

        for(int pointIndex=0; pointIndex<pointsCount; pointIndex++) {
            if (pointsCount >= 3 && pointIndex >= 2) {
                PointF a = points3.get(pointIndex - 1);
                PointF b = points3.get(pointIndex);
                path.moveTo(a.x, a.y);
                path.lineTo(b.x, b.y);
            } else if (pointsCount >= 2 && pointIndex >= 1) {
                PointF a = points3.get(pointIndex - 1);
                PointF b = points3.get(pointIndex);
                path.moveTo(a.x, a.y);
                path.lineTo(b.x, b.y);
            } else if (pointsCount >= 1) {
                PointF a = points3.get(pointIndex);
                path.moveTo(a.x, a.y);
                path.lineTo(a.x, a.y);
            }
        }
        return path;
    }

    private Path evaluatePath4() {
        int pointsCount = points4.size();
        Path path = new Path();

        for(int pointIndex=0; pointIndex<pointsCount; pointIndex++) {
            if (pointsCount >= 3 && pointIndex >= 2) {
                PointF a = points4.get(pointIndex - 1);
                PointF b = points4.get(pointIndex);
                path.moveTo(a.x, a.y);
                path.lineTo(b.x, b.y);
            } else if (pointsCount >= 2 && pointIndex >= 1) {
                PointF a = points4.get(pointIndex - 1);
                PointF b = points4.get(pointIndex);
                path.moveTo(a.x, a.y);
                path.lineTo(b.x, b.y);
            } else if (pointsCount >= 1) {
                PointF a = points4.get(pointIndex);
                path.moveTo(a.x, a.y);
                path.lineTo(a.x, a.y);
            }
        }
        return path;
    }

    private void addPointToPath(Path path, PointF tPoint, PointF pPoint, PointF point) {
        PointF mid1 = new PointF((pPoint.x + tPoint.x) * 0.5f, (pPoint.y + tPoint.y) * 0.5f);
        PointF mid2 = new PointF((point.x + pPoint.x) * 0.5f, (point.y + pPoint.y) * 0.5f);
        path.moveTo(mid1.x, mid1.y);
        path.quadTo(pPoint.x, pPoint.y, mid2.x, mid2.y);
    }
}
